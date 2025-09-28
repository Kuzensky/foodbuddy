import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AppAuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _firebaseService.currentUser;
  
  // Initialize auth state
  void initialize() {
    _firebaseService.authStateChanges.listen((User? user) {
      notifyListeners();
    });
  }
  
  // Email sign up
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final error = await _firebaseService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      
      _setLoading(false);
      
      if (error != null) {
        _errorMessage = error;
        notifyListeners();
        return false;
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Unexpected error in signUp: $e');
      _setLoading(false);
      _errorMessage = 'An unexpected error occurred during sign up';
      notifyListeners();
      return false;
    }
  }
  
  // Email sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final error = await _firebaseService.signInWithEmail(
        email: email,
        password: password,
      );
      
      _setLoading(false);
      
      if (error != null) {
        _errorMessage = error;
        notifyListeners();
        return false;
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Unexpected error in signIn: $e');
      _setLoading(false);
      _errorMessage = 'An unexpected error occurred during sign in';
      notifyListeners();
      return false;
    }
  }
  
  // Google sign in with additional error handling
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      // Add a small delay to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 100));
      
      final error = await _firebaseService.signInWithGoogle();
      
      _setLoading(false);
      
      if (error != null) {
        _errorMessage = error;
        notifyListeners();
        return false;
      }
      
      // Additional check to ensure user is properly signed in
      if (_firebaseService.currentUser == null) {
        _errorMessage = 'Sign in completed but user state is not updated. Please try again.';
        notifyListeners();
        return false;
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected error in signInWithGoogle: $e');
        debugPrint('Error details: ${e.toString()}');
      }
      _setLoading(false);
      
      // Handle the specific PigeionUserDetails error
      if (e.toString().contains('PigeionUserDetails') || 
          e.toString().contains('List<Object?>')) {
        _errorMessage = 'Google Sign In encountered a compatibility issue. Please try email sign in instead.';
      } else {
        _errorMessage = 'An unexpected error occurred during Google sign in';
      }
      
      notifyListeners();
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Error during sign out: $e');
      // Still notify listeners even if sign out had issues
      notifyListeners();
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}