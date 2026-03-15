// lib/models/user_model.dart
// ===========================
// Mirrors the Flutter app's auth_service.dart AppUser + UserModel

import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

enum UserRole { student, teacher, admin }

// ─────────────────────────────────────────────────────────────────────────────
// APP USER — the authenticated user with role
// ─────────────────────────────────────────────────────────────────────────────

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? classroomId;
  final String? schoolId;
  final String? photoUrl;
  final String? employeeId;
  final String? phoneNumber;
  final String? designation;
  final String? department;
  final String? qualification;
  final String? address;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.classroomId,
    this.schoolId,
    this.photoUrl,
    this.employeeId,
    this.phoneNumber,
    this.designation,
    this.department,
    this.qualification,
    this.address,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => UserRole.student,
      ),
      classroomId: map['classroomId'],
      schoolId: map['schoolId'],
      photoUrl: map['photoUrl'],
      employeeId: map['employeeId'],
      phoneNumber: map['phoneNumber'],
      designation: map['designation'],
      department: map['department'],
      qualification: map['qualification'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'name': name,
    'role': role.name,
    if (classroomId != null) 'classroomId': classroomId,
    if (schoolId != null) 'schoolId': schoolId,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (employeeId != null) 'employeeId': employeeId,
    if (phoneNumber != null) 'phoneNumber': phoneNumber,
    if (designation != null) 'designation': designation,
    if (department != null) 'department': department,
    if (qualification != null) 'qualification': qualification,
    if (address != null) 'address': address,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// SOCIAL AUTH RESULT — used by Google Sign-In flow
// ─────────────────────────────────────────────────────────────────────────────

class SocialAuthResult {
  final AppUser? appUser;
  final dynamic firebaseUser; // User from firebase_auth
  final bool isNewUser;

  const SocialAuthResult({
    required this.appUser,
    required this.firebaseUser,
    required this.isNewUser,
  });
}
