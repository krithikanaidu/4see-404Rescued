// lib/models/student_model.dart
// ==============================
// Merges both model/student_model.dart and firebase_service.dart StudentModel
// from the Flutter app into a single comprehensive model for the website.

import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// RISK LEVEL ENUM
// ─────────────────────────────────────────────────────────────────────────────

enum RiskLevel { none, low, medium, high }

RiskLevel riskFromString(String? s) {
  switch (s?.toUpperCase()) {
    case 'HIGH':
      return RiskLevel.high;
    case 'MEDIUM':
      return RiskLevel.medium;
    case 'LOW':
      return RiskLevel.low;
    default:
      return RiskLevel.none;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STUDENT MODEL — full ML feature set + display fields
// ─────────────────────────────────────────────────────────────────────────────

class StudentModel {
  final String id; // Firestore document ID
  final String name;
  final String? studentId; // display-only e.g. "#01245"
  final int age;
  final int g1;
  final int g2;
  final int absences;
  final int failures;
  final int studytime;
  final int health;
  final int internet;
  final int schoolsup;
  final int famsup;
  final int famsize;
  final int address;
  final int school;
  final int pstatus;
  final int medu;
  final int fedu;
  final int dalc;
  final int walc;
  final int goout;
  final String? standard;
  final String? phone;
  final String? className;
  final String? subject;
  final RiskLevel riskLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudentModel({
    required this.id,
    required this.name,
    this.studentId,
    this.age = 0,
    this.g1 = 0,
    this.g2 = 0,
    this.absences = 0,
    this.failures = 0,
    this.studytime = 0,
    this.health = 0,
    this.internet = 0,
    this.schoolsup = 0,
    this.famsup = 0,
    this.famsize = 0,
    this.address = 0,
    this.school = 0,
    this.pstatus = 0,
    this.medu = 0,
    this.fedu = 0,
    this.dalc = 0,
    this.walc = 0,
    this.goout = 0,
    this.standard,
    this.phone,
    this.className,
    this.subject,
    this.riskLevel = RiskLevel.none,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? const _Now(),
        updatedAt = updatedAt ?? const _Now();

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
  String get infoPill => '${standard ?? "N/A"}  |  ${phone ?? "N/A"}';

  // UI Getters
  double get attendance => (93 - absences).clamp(0, 93) / 93; // Approx school days in a term
  double get avgScore => (g1 + g2) / 40.0; // Max score 20+20=40

  // ── From Firestore ──────────────────────────────────────────────────────

  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return StudentModel(
      id: doc.id,
      name: d['name'] as String? ?? d['title'] as String? ?? '',
      studentId: d['studentId'] as String? ?? d['id'] as String?,
      age: (d['age'] as num?)?.toInt() ?? 0,
      g1: (d['G1'] as num?)?.toInt() ?? (d['marks'] as Map?)?['G1']?.toInt() ?? 0,
      g2: (d['G2'] as num?)?.toInt() ?? (d['marks'] as Map?)?['G2']?.toInt() ?? 0,
      absences: (d['absences'] as num?)?.toInt() ?? (d['attendance'] as num?)?.toInt() ?? 0,
      failures: (d['failures'] as num?)?.toInt() ?? 0,
      studytime: (d['studytime'] as num?)?.toInt() ?? 0,
      health: (d['health'] as num?)?.toInt() ?? 0,
      internet: (d['internet'] as num?)?.toInt() ?? 0,
      schoolsup: (d['schoolsup'] as num?)?.toInt() ?? 0,
      famsup: (d['famsup'] as num?)?.toInt() ?? 0,
      famsize: (d['famsize'] as num?)?.toInt() ?? 0,
      address: (d['address'] as num?)?.toInt() ?? 0,
      school: (d['school'] as num?)?.toInt() ?? 0,
      pstatus: (d['Pstatus'] as num?)?.toInt() ?? 0,
      medu: (d['Medu'] as num?)?.toInt() ?? 0,
      fedu: (d['Fedu'] as num?)?.toInt() ?? 0,
      dalc: (d['Dalc'] as num?)?.toInt() ?? 0,
      walc: (d['Walc'] as num?)?.toInt() ?? 0,
      goout: (d['goout'] as num?)?.toInt() ?? 0,
      standard: d['standard'] as String? ?? d['std'] as String?,
      phone: d['phone'] as String?,
      className: d['className'] as String?,
      subject: d['subject'] as String?,
      riskLevel: riskFromString(d['riskLevel'] as String? ?? d['prediction']?['riskLevel'] as String?),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ── To JSON (for API / Firestore writes) ────────────────────────────────

  Map<String, dynamic> toJson() => {
    'name': name,
    if (studentId != null) 'studentId': studentId,
    'age': age,
    'G1': g1,
    'G2': g2,
    'absences': absences,
    'failures': failures,
    'studytime': studytime,
    'health': health,
    'internet': internet,
    'schoolsup': schoolsup,
    'famsup': famsup,
    'famsize': famsize,
    'address': address,
    'school': school,
    'Pstatus': pstatus,
    'Medu': medu,
    'Fedu': fedu,
    'Dalc': dalc,
    'Walc': walc,
    'goout': goout,
    if (standard != null) 'standard': standard,
    if (phone != null) 'phone': phone,
    if (className != null) 'className': className,
    if (subject != null) 'subject': subject,
    'riskLevel': riskLevel.name,
  };

  Map<String, dynamic> toFirestore() => {
    ...toJson(),
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

// Helper so const constructor can have default DateTime
class _Now implements DateTime {
  const _Now();
  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now().noSuchMethod(invocation);
}
