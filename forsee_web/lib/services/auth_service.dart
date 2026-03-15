// lib/services/auth_service.dart
// ===============================
// Mirrors the Flutter app's auth_service.dart
// Handles email/password auth, Google Sign-In, and role-based user management.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '39206056356-p6aicgsrvvnsdrdo5s67o48qibbo3i5j.apps.googleusercontent.com',
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── Fetch current AppUser from Firestore ──────────────────────────────────

  Future<AppUser?> fetchCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Direct doc lookup (normal sign-up users)
    final directDoc = await _db.collection('users').doc(user.uid).get();
    if (directDoc.exists) {
      return AppUser.fromMap(directDoc.data()!, user.uid);
    }

    // Fallback: query by uid field (seeded users)
    final snap = await _db
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return AppUser.fromMap(snap.docs.first.data(), user.uid);
  }

  // ── Email Sign Up ─────────────────────────────────────────────────────────

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? classroomId,
    String? schoolId,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final appUser = AppUser(
      uid: cred.user!.uid,
      email: email,
      name: name,
      role: role,
      classroomId: classroomId,
      schoolId: schoolId,
    );

    await _db.collection('users').doc(cred.user!.uid).set(appUser.toMap());
    return appUser;
  }

  // ── Email Login ───────────────────────────────────────────────────────────

  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    return fetchCurrentAppUser();
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<SocialAuthResult> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    final firebaseUser = userCred.user!;
    final isNewUser = userCred.additionalUserInfo?.isNewUser ?? false;

    AppUser? appUser;
    if (!isNewUser) {
      appUser = await fetchCurrentAppUser();
    }

    return SocialAuthResult(
      appUser: appUser,
      firebaseUser: firebaseUser,
      isNewUser: isNewUser,
    );
  }

  // ── Create user profile after Google sign-in ──────────────────────────────

  Future<AppUser> createUserProfile({
    required String uid,
    required String email,
    required String name,
    required UserRole role,
    String? photoUrl,
    String? classroomId,
    String? schoolId,
  }) async {
    final appUser = AppUser(
      uid: uid,
      email: email,
      name: name,
      role: role,
      photoUrl: photoUrl,
      classroomId: classroomId,
      schoolId: schoolId,
    );

    await _db.collection('users').doc(uid).set(appUser.toMap());
    return appUser;
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
