// lib/models/prediction_model.dart
// =================================
// Mirrors ApiService models from the Flutter app:
//   - PredictionResult (from /predict endpoint)
//   - InsightSession (from /insights endpoint + Firestore llm_insights)
//   - InsightsResult (wrapper for insights response)

import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PREDICTION RESULT — from ML model /predict endpoint
// ─────────────────────────────────────────────────────────────────────────────

class PredictionResult {
  final String riskLevel;
  final double riskScore;
  final String confidence;
  final double dropoutProbability;
  final List<String> riskFactors;
  final String recommendation;
  final double mentalHealthScore;
  final double behaviourScore;

  const PredictionResult({
    required this.riskLevel,
    required this.riskScore,
    required this.confidence,
    required this.dropoutProbability,
    required this.riskFactors,
    required this.recommendation,
    required this.mentalHealthScore,
    required this.behaviourScore,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final ai = json['ai_counselor'] as Map<String, dynamic>? ?? {};
    final riskScore = (json['risk_score'] ?? 0).toDouble();
    final level = json['risk_level'] as String? ?? 'UNKNOWN';

    final confidence =
        level == 'HIGH' ? 'High' : level == 'MEDIUM' ? 'Medium' : 'Low';

    final rawFactors = json['risk_factors'];
    List<String> factors = [];
    if (rawFactors is List) {
      factors = rawFactors.map((e) => e.toString()).toList();
    } else if (rawFactors is Map<String, dynamic>) {
      factors = rawFactors.entries.map((e) => '${e.key}: ${e.value}').toList();
    }

    final rec = [
      ai['risk_summary'] ?? '',
      ai['teacher_action'] ?? '',
      ai['long_term_plan'] ?? '',
    ].where((s) => s.isNotEmpty).join('\n\n');

    return PredictionResult(
      riskLevel: level,
      riskScore: riskScore / 100,
      confidence: confidence,
      dropoutProbability: riskScore,
      riskFactors: factors,
      recommendation: rec,
      mentalHealthScore: (json['mental_health_score'] ?? 0).toDouble(),
      behaviourScore: (json['behaviour_score'] ?? 0).toDouble(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREDICTION MODEL — stored in Firestore predictions/{studentId}
// ─────────────────────────────────────────────────────────────────────────────

class PredictionModel {
  final String id;
  final String studentId;
  final String riskLevel;
  final double riskScore;
  final String confidence;
  final double dropoutProbability;
  final List<String> riskFactors;
  final String recommendation;
  final Map<String, dynamic> inputFeatures;
  final DateTime createdAt;

  PredictionModel({
    required this.id,
    required this.studentId,
    required this.riskLevel,
    required this.riskScore,
    required this.confidence,
    required this.dropoutProbability,
    required this.riskFactors,
    required this.recommendation,
    required this.inputFeatures,
    required this.createdAt,
  });

  factory PredictionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PredictionModel(
      id: doc.id,
      studentId: d['studentId'] as String? ?? '',
      riskLevel: d['riskLevel'] as String? ?? '',
      riskScore: (d['riskScore'] as num?)?.toDouble() ?? 0,
      confidence: d['confidence'] as String? ?? '',
      dropoutProbability: (d['dropoutProbability'] as num?)?.toDouble() ?? 0,
      riskFactors: List<String>.from(d['riskFactors'] as List? ?? []),
      recommendation: d['recommendation'] as String? ?? '',
      inputFeatures: d['inputFeatures'] as Map<String, dynamic>? ?? {},
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHT SESSION — one entry in llm_insights/{studentId}/sessions/{autoId}
// ─────────────────────────────────────────────────────────────────────────────

class InsightSession {
  final String sessionId;
  final String date; // "DD MMM YYYY"
  final String tab; // "Mental Health" | "Academics" | "Attendance"
  final String riskLevel;
  final List<String> insights;
  final DateTime timestamp;
  final double? mentalHealthScore;
  final double? behaviourScore;
  final double? attendancePct;
  final double? g1;
  final double? g2;

  const InsightSession({
    required this.sessionId,
    required this.date,
    required this.tab,
    required this.riskLevel,
    required this.insights,
    required this.timestamp,
    this.mentalHealthScore,
    this.behaviourScore,
    this.attendancePct,
    this.g1,
    this.g2,
  });

  factory InsightSession.fromFirestore(String id, Map<String, dynamic> data) {
    final ts = data['timestamp'];
    final dt = ts is Timestamp ? ts.toDate() : DateTime.now();
    return InsightSession(
      sessionId: id,
      date: data['date'] as String? ?? '',
      tab: data['tab'] as String? ?? '',
      riskLevel: data['risk_level'] as String? ?? 'LOW',
      insights: List<String>.from(data['insights'] as List? ?? []),
      timestamp: dt,
      mentalHealthScore: (data['mental_health_score'] as num?)?.toDouble(),
      behaviourScore: (data['behaviour_score'] as num?)?.toDouble(),
      attendancePct: (data['attendance_pct'] as num?)?.toDouble(),
      g1: (data['g1'] as num?)?.toDouble(),
      g2: (data['g2'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toApiJson() => {
    'date': date,
    'tab': tab,
    'risk_level': riskLevel,
    'insights': insights,
    'mental_health_score': mentalHealthScore,
    'behaviour_score': behaviourScore,
    'attendance_pct': attendancePct,
    'g1': g1,
    'g2': g2,
  };

  Map<String, dynamic> toFirestore() => {
    'date': date,
    'tab': tab,
    'risk_level': riskLevel,
    'insights': insights,
    'timestamp': Timestamp.fromDate(timestamp),
    'mental_health_score': mentalHealthScore,
    'behaviour_score': behaviourScore,
    'attendance_pct': attendancePct,
    'g1': g1,
    'g2': g2,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHTS RESULT — wrapper returned by ApiService.getInsights()
// ─────────────────────────────────────────────────────────────────────────────

class InsightsResult {
  final String tab;
  final List<String> insights;
  final List<InsightSession> history;

  const InsightsResult({
    required this.tab,
    required this.insights,
    required this.history,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PREDICTION SERVICE DATA CLASSES
// ─────────────────────────────────────────────────────────────────────────────

class AttendanceData {
  final String studentId;
  final int totalDays;
  final int presentDays;

  const AttendanceData({
    required this.studentId,
    required this.totalDays,
    required this.presentDays,
  });

  int get absences => totalDays - presentDays;

  Map<String, dynamic> toJson() => {
    'totalDays': totalDays,
    'presentDays': presentDays,
    'absences': absences,
  };
}

class MarksData {
  final String studentId;
  final int g1;
  final int g2;
  final int maxMarks;
  final bool passed;

  const MarksData({
    required this.studentId,
    required this.g1,
    required this.g2,
    required this.maxMarks,
    required this.passed,
  });

  int get g1Normalized => ((g1 / maxMarks) * 20).round().clamp(0, 20);
  int get g2Normalized => ((g2 / maxMarks) * 20).round().clamp(0, 20);
  double get averagePct => ((g1 + g2) / (maxMarks * 2)) * 100;

  Map<String, dynamic> toJson() => {
    'g1Raw': g1,
    'g2Raw': g2,
    'maxMarks': maxMarks,
    'G1': g1Normalized,
    'G2': g2Normalized,
    'passed': passed,
    'avgPct': averagePct,
  };
}

class BehaviourData {
  final String studentId;
  final List<String> negativeTags;
  final List<String> positiveTags;

  const BehaviourData({
    required this.studentId,
    required this.negativeTags,
    required this.positiveTags,
  });

  double get behaviourScore {
    final negScore = (negativeTags.length * 10.0).clamp(0.0, 100.0);
    final posScore = (positiveTags.length * 10.0).clamp(0.0, 100.0);
    return (negScore - posScore + 50).clamp(0.0, 100.0);
  }

  Map<String, dynamic> toJson() => {
    'negativeTags': negativeTags,
    'positiveTags': positiveTags,
    'behaviourScore': behaviourScore,
  };
}

class BehaviourIncident {
  final String studentId;
  final String description;
  final DateTime date;

  const BehaviourIncident({
    required this.studentId,
    required this.description,
    required this.date,
  });
}

class QuizScoreData {
  final String studentId;
  final double overallScore;
  final Map<String, double> categoryScores;

  const QuizScoreData({
    required this.studentId,
    required this.overallScore,
    required this.categoryScores,
  });

  double get mentalHealthScore => overallScore;

  Map<String, dynamic> toJson() => {
    'overallScore': overallScore,
    'categoryScores': categoryScores,
    'mentalHealthScore': mentalHealthScore,
  };
}
