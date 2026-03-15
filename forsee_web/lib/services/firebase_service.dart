// lib/services/firebase_service.dart
// ====================================
// Core Firestore CRUD — mirrors the Flutter app's firebase_service.dart
// Handles students, predictions, classrooms, and quiz data.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ─────────────────────────────────────────────────────────────────────────
  // STUDENTS
  // ─────────────────────────────────────────────────────────────────────────

  /// Get all students in a classroom
  Stream<QuerySnapshot> getStudentsByClassroom(String classroomId) {
    return _db
        .collection('students')
        .where('classroomId', isEqualTo: classroomId)
        .snapshots();
  }

  /// Get a single student by document ID
  Future<DocumentSnapshot> getStudent(String studentId) {
    return _db.collection('students').doc(studentId).get();
  }

  /// Add a new student
  Future<DocumentReference> addStudent(Map<String, dynamic> data) {
    return _db.collection('students').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update a student
  Future<void> updateStudent(String id, Map<String, dynamic> data) {
    return _db.collection('students').doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a student
  Future<void> deleteStudent(String id) {
    return _db.collection('students').doc(id).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PREDICTIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Save prediction result for a student
  Future<void> savePrediction({
    required String studentId,
    required String riskLevel,
    required double riskScore,
    required String confidence,
    required double dropoutProbability,
    required List<String> riskFactors,
    required String recommendation,
    required Map<String, dynamic> inputFeatures,
  }) async {
    // Write to predictions collection
    await _db.collection('predictions').doc(studentId).set({
      'studentId': studentId,
      'riskLevel': riskLevel,
      'riskScore': riskScore,
      'confidence': confidence,
      'dropoutProbability': dropoutProbability,
      'riskFactors': riskFactors,
      'recommendation': recommendation,
      'inputFeatures': inputFeatures,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Also update student's riskLevel
    await _db.collection('students').doc(studentId).set({
      'riskLevel': riskLevel,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get prediction for a student
  Future<DocumentSnapshot> getPrediction(String studentId) {
    return _db.collection('predictions').doc(studentId).get();
  }

  /// Stream all predictions (for admin/teacher dashboards)
  Stream<QuerySnapshot> getPredictionsStream() {
    return _db.collection('predictions').snapshots();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CLASSROOMS
  // ─────────────────────────────────────────────────────────────────────────

  /// Get classrooms for the current teacher
  Stream<QuerySnapshot> getTeacherClassrooms(String teacherId) {
    return _db
        .collection('classrooms')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots();
  }

  /// Create a new classroom
  Future<DocumentReference> createClassroom(Map<String, dynamic> data) {
    return _db.collection('classrooms').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get a single classroom
  Future<DocumentSnapshot> getClassroom(String classroomId) {
    return _db.collection('classrooms').doc(classroomId).get();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // QUIZ DATA
  // ─────────────────────────────────────────────────────────────────────────

  /// Save quiz result for a student
  Future<void> saveQuizResult({
    required String studentId,
    required String category,
    required int score,
    required String severity,
    required Map<String, dynamic> answers,
  }) async {
    await _db
        .collection('students')
        .doc(studentId)
        .collection('quizResults')
        .add({
      'category': category,
      'score': score,
      'severity': severity,
      'answers': answers,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get quiz results for a student
  Stream<QuerySnapshot> getQuizResults(String studentId) {
    return _db
        .collection('students')
        .doc(studentId)
        .collection('quizResults')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FEEDBACK
  // ─────────────────────────────────────────────────────────────────────────

  /// Save teacher feedback for a student
  Future<void> saveFeedback({
    required String studentId,
    required String teacherId,
    required String feedback,
  }) async {
    await _db
        .collection('students')
        .doc(studentId)
        .collection('feedback')
        .add({
      'teacherId': teacherId,
      'feedback': feedback,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get feedback for a student
  Stream<QuerySnapshot> getFeedback(String studentId) {
    return _db
        .collection('students')
        .doc(studentId)
        .collection('feedback')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADMIN STATS
  // ─────────────────────────────────────────────────────────────────────────

  /// Get total student count
  Future<int> getTotalStudentCount() async {
    final snap = await _db.collection('students').count().get();
    return snap.count ?? 0;
  }

  /// Get total teacher count
  Future<int> getTotalTeacherCount() async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .count()
        .get();
    return snap.count ?? 0;
  }

  /// Get high-risk student count
  Future<int> getHighRiskCount() async {
    final snap = await _db
        .collection('students')
        .where('riskLevel', isEqualTo: 'HIGH')
        .count()
        .get();
    return snap.count ?? 0;
  }
}
