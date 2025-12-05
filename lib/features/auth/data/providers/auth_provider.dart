import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartsan_app/features/auth/data/models/user_model.dart';
import 'package:smartsan_app/features/auth/domain/services/auth_service.dart';


class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // Listen to changes in the authentication state
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // Fetch the user's custom profile data from the database here
        // For now, we'll just create a placeholder
        _currentUser = UserModel(
          uid: user.uid,
          email: user.email ?? 'N/A',
          name: 'Loading Name...', // Should be fetched from DB
          role: 'Community',
        );
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      final userCredential = await _authService.signUp(email, password);
      notifyListeners();
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUserRecord(UserModel userModel) async {
    try {
      await _authService.createUserRecord(userModel);
      _currentUser = userModel;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _authService.signIn(email, password);
    } catch (e) {
      // Handle error and re-throw
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}