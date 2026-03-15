// lib/services/api_service.dart
// ==============================
// Mirrors the Flutter app's api_service.dart
// Connects to the Hugging Face ML endpoint for predictions and LLM insights.

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';
import '../models/prediction_model.dart';

const String kBaseUrl = 'https://varlett-4seedemo.hf.space';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _firebase = FirebaseService();
  final _db = FirebaseFirestore.instance;

  // ── Firestore path for LLM insights ────────────────────────────────────
  CollectionReference _sessionsRef(String studentId) => _db
      .collection('llm_insights')
      .doc(studentId)
      .collection('sessions');

  // ── Health check ───────────────────────────────────────────────────────

  Future<bool> checkHealth() async {
    try {
      final r = await http
          .get(Uri.parse('$kBaseUrl/health'))
          .timeout(const Duration(seconds: 10));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── PREDICT + SAVE ─────────────────────────────────────────────────────

  Future<PredictionResult> predictAndSave({
    required String studentId,
    required Map<String, dynamic> studentData,
  }) async {
    final resp = await http
        .post(
          Uri.parse('$kBaseUrl/predict'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(_mapToApiInput(studentData)),
        )
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode != 200) {
      throw Exception(
        (jsonDecode(resp.body) as Map)['detail'] ?? 'Prediction failed',
      );
    }

    final result = PredictionResult.fromJson(jsonDecode(resp.body));

    await _firebase.savePrediction(
      studentId: studentId,
      riskLevel: result.riskLevel,
      riskScore: result.riskScore,
      confidence: result.confidence,
      dropoutProbability: result.dropoutProbability,
      riskFactors: result.riskFactors,
      recommendation: result.recommendation,
      inputFeatures: studentData,
    );

    return result;
  }

  // ── GET INSIGHTS (LONGITUDINAL) ────────────────────────────────────────
  // 1. Fetch ALL past sessions for this student + tab from Firestore
  // 2. Call /insights with current data + full history
  // 3. Save the new session back to Firestore
  // 4. Return new insights + updated history

  Future<InsightsResult> getInsights({
    required String studentId,
    required String tab,
    required Map<String, dynamic> currentData,
  }) async {
    // 1. Fetch history from Firestore
    final historySnap = await _sessionsRef(studentId)
        .where('tab', isEqualTo: tab)
        .orderBy('timestamp')
        .get();

    final history = historySnap.docs
        .map((doc) =>
            InsightSession.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
        .toList();

    // 2. Build request body
    final body = {
      'tab': tab,
      'student_data': currentData,
      'history': history.map((s) => s.toApiJson()).toList(),
    };

    final resp = await http
        .post(
          Uri.parse('$kBaseUrl/insights'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 60));

    if (resp.statusCode != 200) {
      throw Exception('Insights request failed: ${resp.statusCode}');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final newInsights = List<String>.from(json['insights'] as List? ?? []);
    final riskLevel = json['risk_level'] as String? ?? 'LOW';

    // 3. Save new session to Firestore
    final now = DateTime.now();
    final newSession = InsightSession(
      sessionId: '',
      date: '${now.day} ${_monthName(now.month)} ${now.year}',
      tab: tab,
      riskLevel: riskLevel,
      insights: newInsights,
      timestamp: now,
      mentalHealthScore: (currentData['mental_health_score'] as num?)?.toDouble(),
      behaviourScore: (currentData['behaviour_score'] as num?)?.toDouble(),
      attendancePct: (currentData['attendance_pct'] as num?)?.toDouble(),
      g1: (currentData['g1'] as num?)?.toDouble(),
      g2: (currentData['g2'] as num?)?.toDouble(),
    );

    await _sessionsRef(studentId).add(newSession.toFirestore());

    // 4. Return updated history
    history.add(newSession);
    return InsightsResult(
      tab: tab,
      insights: newInsights,
      history: history,
    );
  }

  // ── Map student data to API input format ───────────────────────────────

  Map<String, dynamic> _mapToApiInput(Map<String, dynamic> data) {
    return {
      'age': data['age'] ?? 0,
      'Medu': data['Medu'] ?? 0,
      'Fedu': data['Fedu'] ?? 0,
      'studytime': data['studytime'] ?? 0,
      'failures': data['failures'] ?? 0,
      'famrel': data['famrel'] ?? 4,
      'freetime': data['freetime'] ?? 3,
      'goout': data['goout'] ?? 0,
      'Dalc': data['Dalc'] ?? 0,
      'Walc': data['Walc'] ?? 0,
      'health': data['health'] ?? 0,
      'absences': data['absences'] ?? 0,
      'G1': data['G1'] ?? 0,
      'G2': data['G2'] ?? 0,
      'school': data['school'] ?? 0,
      'sex': data['sex'] ?? 0,
      'address': data['address'] ?? 0,
      'famsize': data['famsize'] ?? 0,
      'Pstatus': data['Pstatus'] ?? 0,
      'schoolsup': data['schoolsup'] ?? 0,
      'famsup': data['famsup'] ?? 0,
      'paid': data['paid'] ?? 0,
      'activities': data['activities'] ?? 0,
      'nursery': data['nursery'] ?? 0,
      'higher': data['higher'] ?? 1,
      'internet': data['internet'] ?? 0,
      'romantic': data['romantic'] ?? 0,
      // Mental health + behaviour scores (from quizzes / incidents)
      'mental_health_score': data['mental_health_score'] ?? 0,
      'behaviour_score': data['behaviour_score'] ?? 50,
    };
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m];
  }
}
