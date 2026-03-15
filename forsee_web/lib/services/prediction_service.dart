// lib/services/prediction_service.dart
// =====================================
// Mirrors the Flutter app's prediction_service.dart
// Orchestrates data collection (attendance, marks, behaviour, quiz)
// and triggers ML predictions via ApiService.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'api_service.dart';
import '../models/prediction_model.dart';

class PredictionService {
  static final PredictionService _instance = PredictionService._internal();
  factory PredictionService() => _instance;
  PredictionService._internal();

  final _db = FirebaseFirestore.instance;
  final _api = ApiService();

  // ── SAVE ATTENDANCE ────────────────────────────────────────────────────

  Future<void> saveAttendance(AttendanceData data) async {
    // Accumulate cumulative totals on student doc
    await _db.collection('students').doc(data.studentId).set({
      'totalDays': FieldValue.increment(data.totalDays),
      'presentDays': FieldValue.increment(data.presentDays),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Stage snapshot for ML payload
    await _db.collection('staging').doc(data.studentId).set({
      'attendance': data.toJson(),
      'attendanceAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _classifyAndWrite(data.studentId);
  }

  // ── SAVE MARKS ─────────────────────────────────────────────────────────

  Future<void> saveMarks(MarksData data) async {
    await _db.collection('students').doc(data.studentId).set({
      'averageMarks': data.averagePct,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _db.collection('staging').doc(data.studentId).set({
      'marks': data.toJson(),
      'marksAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _classifyAndWrite(data.studentId);
  }

  // ── SAVE BEHAVIOUR ─────────────────────────────────────────────────────

  Future<void> saveBehaviour(BehaviourData data) async {
    await _db.collection('staging').doc(data.studentId).set({
      'behaviour': data.toJson(),
      'behaviourAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _classifyAndWrite(data.studentId);
  }

  // ── LOG BEHAVIOUR INCIDENT ─────────────────────────────────────────────

  Future<void> saveBehaviourIncident(BehaviourIncident incident) async {
    final studentRef = _db.collection('students').doc(incident.studentId);
    final severity = _incidentSeverity(incident.description);

    // Log to audit trail
    await studentRef.collection('behaviourLog').add({
      'description': incident.description,
      'date': Timestamp.fromDate(incident.date),
      'severity': severity,
    });

    // Accumulate penalty on student doc
    await _db.runTransaction((tx) async {
      final snap = await tx.get(studentRef);
      final existing = snap.data() ?? {};
      tx.set(
        studentRef,
        {
          'incidentCount':
              ((existing['incidentCount'] as num?)?.toInt() ?? 0) + 1,
          'behaviourPenalty':
              ((existing['behaviourPenalty'] as num?)?.toDouble() ?? 0.0) +
                  severity,
          'lastIncident': incident.description,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    // Sync to staging
    final updatedSnap = await studentRef.get();
    final updatedData = updatedSnap.data() ?? {};
    final totalPenalty =
        (updatedData['behaviourPenalty'] as num?)?.toDouble() ?? 0.0;
    final count = (updatedData['incidentCount'] as num?)?.toInt() ?? 1;
    final behaviourScore = (50.0 + (totalPenalty * 5.0)).clamp(0.0, 100.0);

    await _db.collection('staging').doc(incident.studentId).set({
      'behaviour': {
        'negativeTags': List.generate(count, (i) => 'Incident ${i + 1}'),
        'positiveTags': <String>[],
        'behaviourScore': behaviourScore,
        'incidentCount': count,
        'totalPenalty': totalPenalty,
      },
      'behaviourAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _classifyAndWrite(incident.studentId);
  }

  // ── SAVE QUIZ ──────────────────────────────────────────────────────────

  Future<void> saveQuiz(QuizScoreData data) async {
    await _db.collection('staging').doc(data.studentId).set({
      'quiz': data.toJson(),
      'quizAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _classifyAndWrite(data.studentId);
  }

  // ── TRIGGER PREDICTION ─────────────────────────────────────────────────

  Future<void> triggerPrediction(String studentId) => _classifyAndWrite(studentId);

  // ── CLASSIFY AND WRITE ─────────────────────────────────────────────────
  Future<void> _classifyAndWrite(String studentId) async {
    final stagingSnap = await _db.collection('staging').doc(studentId).get();
    final staging = stagingSnap.data() ?? {};

    final studentSnap = await _db.collection('students').doc(studentId).get();
    final studentData = studentSnap.data() ?? {};

    // Merge staging + student data for ML payload
    final merged = <String, dynamic>{
      ...studentData,
      ...staging,
      // Extract nested values
      if (staging['attendance'] != null) ...{
        'absences': staging['attendance']['absences'] ?? 0,
      },
      if (staging['marks'] != null) ...{
        'G1': staging['marks']['G1'] ?? 0,
        'G2': staging['marks']['G2'] ?? 0,
      },
      if (staging['behaviour'] != null) ...{
        'behaviour_score': staging['behaviour']['behaviourScore'] ?? 50,
      },
      if (staging['quiz'] != null) ...{
        'mental_health_score': staging['quiz']['mentalHealthScore'] ?? 0,
      },
    };

    try {
      // Try real ML model
      await _api.predictAndSave(
        studentId: studentId,
        studentData: merged,
      );
    } catch (e) {
      // Fallback: ABC classification
      await _fallbackClassify(studentId, merged);
    }
  }

  // ── Fallback ABC Classification ────────────────────────────────────────

  Future<void> _fallbackClassify(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    double riskScore = 0;
    List<String> factors = [];

    // Absences
    final absences = (data['absences'] as num?)?.toInt() ?? 0;
    if (absences > 20) {
      riskScore += 30;
      factors.add('High absenteeism ($absences days)');
    } else if (absences > 10) {
      riskScore += 15;
      factors.add('Moderate absenteeism ($absences days)');
    }

    // Grades
    final g1 = (data['G1'] as num?)?.toInt() ?? 10;
    final g2 = (data['G2'] as num?)?.toInt() ?? 10;
    final avgGrade = (g1 + g2) / 2;
    if (avgGrade < 8) {
      riskScore += 25;
      factors.add('Low academic performance (avg: ${avgGrade.toStringAsFixed(1)})');
    } else if (avgGrade < 12) {
      riskScore += 10;
      factors.add('Below average grades (avg: ${avgGrade.toStringAsFixed(1)})');
    }

    // Failures
    final failures = (data['failures'] as num?)?.toInt() ?? 0;
    if (failures > 0) {
      riskScore += failures * 10;
      factors.add('Past failures: $failures');
    }

    // Behaviour
    final behaviourScore = (data['behaviour_score'] as num?)?.toDouble() ?? 50;
    if (behaviourScore > 70) {
      riskScore += 15;
      factors.add('Behavioural concerns (score: ${behaviourScore.toStringAsFixed(0)})');
    }

    // Mental health
    final mentalHealth = (data['mental_health_score'] as num?)?.toDouble() ?? 0;
    if (mentalHealth > 60) {
      riskScore += 20;
      factors.add('Mental health concerns (score: ${mentalHealth.toStringAsFixed(0)})');
    }

    riskScore = riskScore.clamp(0, 100);
    final level = riskScore >= 60
        ? 'HIGH'
        : riskScore >= 30
            ? 'MEDIUM'
            : 'LOW';

    await _db.collection('predictions').doc(studentId).set({
      'studentId': studentId,
      'riskLevel': level,
      'riskScore': riskScore / 100,
      'confidence': 'Fallback',
      'dropoutProbability': riskScore,
      'riskFactors': factors,
      'recommendation': 'Based on ABC classification. Run ML model for detailed analysis.',
      'inputFeatures': data,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('students').doc(studentId).set({
      'riskLevel': level,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  double _incidentSeverity(String description) {
    final lower = description.toLowerCase();
    if (lower.contains('fight') || lower.contains('bully')) return 3.0;
    if (lower.contains('disrupt') || lower.contains('cheat')) return 2.0;
    return 1.0;
  }
}
