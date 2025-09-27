import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:async'; // for TimeoutException

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Email/Password Sign Up
  Future<String?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore with timeout
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'uid': credential.user!.uid,
      }).timeout(const Duration(seconds: 10));

      return null; // No error
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return _getErrorMessage(e);
    } on SocketException catch (e) {
      print('Network error: $e');
      return 'Network error. Please check your internet connection.';
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      return 'Request timed out. Please try again.';
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.code} - ${e.message}');
      return 'Firebase error: ${e.message ?? 'Unknown Firebase error'}';
    } catch (e) {
      print('Unexpected error in signUpWithEmail: $e');
      return 'An unexpected error occurred: $e';
    }
  }

  // Email/Password Sign In
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 10));
      return null; // No error
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return _getErrorMessage(e);
    } on SocketException catch (e) {
      print('Network error: $e');
      return 'Network error. Please check your internet connection.';
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      return 'Request timed out. Please try again.';
    } catch (e) {
      print('Unexpected error in signInWithEmail: $e');
      return 'An unexpected error occurred: $e';
    }
  }

  // Google Sign In
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      // Check if user is new, if so, create user document
      if (userCredential.additionalUserInfo!.isNewUser) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          'uid': userCredential.user!.uid,
        }).timeout(const Duration(seconds: 10));
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return _getErrorMessage(e);
    } on SocketException catch (e) {
      print('Network error: $e');
      return 'Network error. Please check your internet connection.';
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      return 'Request timed out. Please try again.';
    } on FirebaseException catch (e) {
      print('Firebase error: ${e.code} - ${e.message}');
      return 'Firebase error: ${e.message ?? 'Unknown Firebase error'}';
    } catch (e) {
      print('Unexpected error in signInWithGoogle: $e');
      return 'An unexpected error occurred: $e';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
      // Don't throw error for sign out issues
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = 
          await _firestore.collection('users').doc(uid).get()
          .timeout(const Duration(seconds: 10));
      return doc.data() as Map<String, dynamic>?;
    } on SocketException catch (e) {
      print('Network error getting user data: $e');
      return null;
    } on TimeoutException catch (e) {
      print('Timeout getting user data: $e');
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Error message helper
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This user has been disabled';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'weak-password':
        return 'Password is too weak';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid credentials provided';
      default:
        print('Unknown FirebaseAuthException: ${e.code} - ${e.message}');
        return e.message ?? 'An authentication error occurred';
    }
  }
}

