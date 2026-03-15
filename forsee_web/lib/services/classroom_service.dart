// lib/services/classroom_service.dart
// =====================================
// Mirrors the Flutter app's classroom_service.dart
// Handles classroom creation, joining, student management, and CSV import.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'firebase_service.dart';
import 'prediction_service.dart';
import '../models/student_model.dart';

class ClassroomService {
  static final ClassroomService _instance = ClassroomService._internal();
  factory ClassroomService() => _instance;
  ClassroomService._internal();

  final _db = FirebaseFirestore.instance;
  final _firebase = FirebaseService();
  final _prediction = PredictionService();

  // ── Create Classroom ──────────────────────────────────────────────────

  Future<String> createClassroom({
    required String name,
    required String teacherId,
    required String subject,
    String? standard,
  }) async {
    final docRef = await _db.collection('classrooms').add({
      'name': name,
      'title': name,
      'teacherId': teacherId,
      'subject': subject,
      'std': standard ?? '',
      'standard': standard ?? '',
      'studentCount': 0,
      'studentIds': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // ── Get Classrooms for Teacher ────────────────────────────────────────

  Stream<QuerySnapshot> getTeacherClassrooms(String teacherId, {bool all = false}) {
    if (all) {
      return _db.collection('classrooms').snapshots();
    }
    return _db
        .collection('classrooms')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots();
  }

  // ── Get Single Classroom ─────────────────────────────────────────────

  Future<DocumentSnapshot> getClassroom(String classroomId) {
    return _db.collection('classrooms').doc(classroomId).get();
  }

  // ── Get Students in Classroom ─────────────────────────────────────────

  Stream<QuerySnapshot> getClassroomStudents(String classroomId) {
    return _db
        .collection('students')
        .where('classroomId', isEqualTo: classroomId)
        .snapshots();
  }

  Future<List<StudentModel>> getStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    // Firestore whereIn limit is 30. For larger classes, we fetch in chunks or individually.
    // For simplicity and since these are small classes, we'll fetch in chunks of 30.
    List<StudentModel> students = [];
    for (var i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
      final snap = await _db
          .collection('students')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      students.addAll(snap.docs.map((doc) => StudentModel.fromFirestore(doc)));
    }
    return students;
  }

  // ── Add Student to Classroom ──────────────────────────────────────────

  Future<String> addStudent({
    required String classroomId,
    required String name,
    required Map<String, dynamic> data,
  }) async {
    final docRef = await _db.collection('students').add({
      ...data,
      'name': name,
      'classroomId': classroomId,
      'riskLevel': 'none',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Increment student count and add to studentIds list
    await _db.collection('classrooms').doc(classroomId).update({
      'studentCount': FieldValue.increment(1),
      'studentIds': FieldValue.arrayUnion([docRef.id]),
    });

    // Trigger initial prediction/fallback assessment
    await _prediction.triggerPrediction(docRef.id);

    return docRef.id;
  }

  // ── Update Student Attendance ────────────────────────────────────────

  Future<void> updateStudentAttendance(String studentId, int absences) async {
    await _db.collection('students').doc(studentId).update({
      'absences': absences,
      'attendance': absences, // Sync both fields for compatibility
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Mirror to staging and trigger prediction
    await _db.collection('staging').doc(studentId).set({
      'attendance': {
        'totalDays': 200, // Placeholder
        'presentDays': 200 - absences,
        'absences': absences,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      'attendanceAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _prediction.triggerPrediction(studentId);
  }

  // ── Update Student Marks ─────────────────────────────────────────────

  Future<void> updateStudentMarks(String studentId, int g1, int g2) async {
    await _db.collection('students').doc(studentId).update({
      'G1': g1,
      'G2': g2,
      'marks': {
        'G1': g1,
        'G2': g2,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Mirror to staging and trigger prediction
    await _db.collection('staging').doc(studentId).set({
      'marks': {
        'G1': g1,
        'G2': g2,
        'averagePct': ((g1 + g2) / 40.0) * 100.0, // Assuming out of 20
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      'marksAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _prediction.triggerPrediction(studentId);
  }

  // ── Remove Student from Classroom ────────────────────────────────────

  Future<void> removeStudent(String studentId, String classroomId) async {
    await _db.collection('students').doc(studentId).delete();
    await _db.collection('classrooms').doc(classroomId).update({
      'studentCount': FieldValue.increment(-1),
    });
  }

  // ── CSV Import ────────────────────────────────────────────────────────
  // Expects CSV with columns: name, age, studentId, standard, phone
  // Additional ML features are optional columns.

  Future<int> importStudentsFromCsv({
    required String classroomId,
    required String csvContent,
  }) async {
    final rows = const CsvToListConverter().convert(csvContent);
    if (rows.isEmpty) return 0;

    // First row is header
    final headers = rows[0].map((e) => e.toString().trim().toLowerCase()).toList();
    int imported = 0;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < headers.length) continue;

      final data = <String, dynamic>{};
      for (int j = 0; j < headers.length; j++) {
        final key = headers[j];
        final value = row[j];

        // Map common CSV headers to Firestore field names
        switch (key) {
          case 'name':
            data['name'] = value.toString();
            break;
          case 'age':
            data['age'] = int.tryParse(value.toString()) ?? 0;
            break;
          case 'studentid':
          case 'student_id':
            data['studentId'] = value.toString();
            break;
          case 'standard':
          case 'class':
            data['standard'] = value.toString();
            break;
          case 'phone':
            data['phone'] = value.toString();
            break;
          case 'g1':
            data['G1'] = int.tryParse(value.toString()) ?? 0;
            break;
          case 'g2':
            data['G2'] = int.tryParse(value.toString()) ?? 0;
            break;
          case 'absences':
            data['absences'] = int.tryParse(value.toString()) ?? 0;
            break;
          case 'failures':
            data['failures'] = int.tryParse(value.toString()) ?? 0;
            break;
          case 'studytime':
            data['studytime'] = int.tryParse(value.toString()) ?? 0;
            break;
          case 'health':
            data['health'] = int.tryParse(value.toString()) ?? 0;
            break;
          default:
            // Pass through other fields
            data[key] = value;
        }
      }

      if (data['name'] != null && data['name'].toString().isNotEmpty) {
        await addStudent(
          classroomId: classroomId,
          name: data['name'],
          data: data,
        );
        imported++;
      }
    }

    return imported;
  }
}
