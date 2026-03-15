// lib/controllers/auth_controller.dart
// ======================================
// ChangeNotifier-based auth state management.
// Wraps AuthService for use with Provider.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _currentUser;
  bool _isLoading = true;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;
  UserRole? get role => _currentUser?.role;

  AuthController() {
    _init();
  }

  // ── Initialize — listen to auth state ─────────────────────────────────

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      if (user == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      } else {
        await _fetchUser();
      }
    });
  }

  Future<void> _fetchUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentUser = await _authService.fetchCurrentAppUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? classroomId,
    String? schoolId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        classroomId: classroomId,
        schoolId: schoolId,
      );
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentUser = await _authService.login(
        email: email,
        password: password,
      );
      return _currentUser != null;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────

  Future<SocialAuthResult?> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _authService.signInWithGoogle();

      if (!result.isNewUser && result.appUser != null) {
        _currentUser = result.appUser;
      }

      return result;
    } catch (e) {
      _error = _friendlyError(e);
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Complete Google Sign-In profile ───────────────────────────────────

  Future<bool> completeGoogleProfile({
    required String uid,
    required String email,
    required String name,
    required UserRole role,
    String? photoUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentUser = await _authService.createUserProfile(
        uid: uid,
        email: email,
        name: name,
        role: role,
        photoUrl: photoUrl,
      );
      return true;
    } catch (e) {
      _error = _friendlyError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      if (_currentUser == null) return false;
      _isLoading = true;
      notifyListeners();

      await _authService.updateUserProfile(_currentUser!.uid, data);
      await _fetchUser(); // Refresh local state
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  // ── Clear error ───────────────────────────────────────────────────────

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Friendly error messages ───────────────────────────────────────────

  String _friendlyError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        default:
          return e.message ?? 'Authentication error occurred.';
      }
    }
    return e.toString();
  }
}
