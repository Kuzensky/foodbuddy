import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../utils/logger.dart';

/// Provider responsible for user profile management and authentication state
class UserProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User data
  Map<String, dynamic>? _currentUserProfile;
  final List<Map<String, dynamic>> _users = [];
  bool _isCurrentUserLoading = false;
  bool _isUsersLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;
  List<Map<String, dynamic>> get users => List.unmodifiable(_users);
  bool get isCurrentUserLoading => _isCurrentUserLoading;
  bool get isUsersLoading => _isUsersLoading;
  String? get error => _error;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;

  /// Load current user profile
  Future<void> loadCurrentUserProfile() async {
    if (!isAuthenticated) return;

    try {
      _isCurrentUserLoading = true;
      _error = null;
      notifyListeners();

      logDatabase('Loading current user profile for: $currentUserId');

      _currentUserProfile = await _db.getCurrentUserProfile();

      if (_currentUserProfile != null) {
        logSuccess('Current user profile loaded successfully');
      } else {
        logWarning('Current user profile not found');
      }

      _isCurrentUserLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Failed to load user profile';
      _isCurrentUserLoading = false;
      logError('Error loading current user profile', e, stackTrace);
      notifyListeners();
    }
  }

  /// Update current user profile
  Future<void> updateCurrentUserProfile(Map<String, dynamic> data) async {
    if (!isAuthenticated) return;

    try {
      logDatabase('Updating current user profile');

      await _db.updateUserProfile(currentUserId!, data);

      // Update local cache
      if (_currentUserProfile != null) {
        _currentUserProfile!.addAll(data);
      }

      logSuccess('Current user profile updated successfully');
      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Failed to update user profile';
      logError('Error updating current user profile', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  /// Load users for discovery/search
  Future<void> loadUsers() async {
    try {
      _isUsersLoading = true;
      _error = null;
      notifyListeners();

      logDatabase('Loading users');

      final users = await _db.getUsers();
      _users.clear();
      _users.addAll(users);

      logSuccess('Loaded ${_users.length} users');

      _isUsersLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Failed to load users';
      _isUsersLoading = false;
      logError('Error loading users', e, stackTrace);
      notifyListeners();
    }
  }

  /// Search users by query
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      logDatabase('Searching users with query: $query');

      final results = await _db.searchUsers(query);

      logSuccess('Found ${results.length} users matching query');

      return results;
    } catch (e, stackTrace) {
      logError('Error searching users', e, stackTrace);
      return [];
    }
  }

  /// Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      logDatabase('Getting user profile for: $userId');

      // Check cache first
      final cachedUser = _users.firstWhere(
        (user) => user['id'] == userId,
        orElse: () => {},
      );

      if (cachedUser.isNotEmpty) {
        logDebug('Returning cached user profile');
        return cachedUser;
      }

      // Fetch from database
      final userProfile = await _db.getUserProfile(userId);

      if (userProfile != null) {
        logSuccess('User profile loaded from database');
        // Add to cache
        _users.removeWhere((user) => user['id'] == userId);
        _users.add(userProfile);
        notifyListeners();
      }

      return userProfile;
    } catch (e, stackTrace) {
      logError('Error getting user profile', e, stackTrace);
      return null;
    }
  }

  /// Clear user data (for logout)
  void clearUserData() {
    logInfo('Clearing user data');

    _currentUserProfile = null;
    _users.clear();
    _isCurrentUserLoading = false;
    _isUsersLoading = false;
    _error = null;

    notifyListeners();
  }

  /// Refresh current user data
  Future<void> refresh() async {
    logInfo('Refreshing user data');

    await Future.wait([
      loadCurrentUserProfile(),
      loadUsers(),
    ]);
  }
}

/// Extension to add logging functionality
extension UserProviderLogging on UserProvider {
  void logDebug(String message) => AppLogger.debug(message, 'UserProvider');
  void logInfo(String message) => AppLogger.info(message, 'UserProvider');
  void logWarning(String message) => AppLogger.warning(message, 'UserProvider');
  void logError(String message, [Object? error, StackTrace? stackTrace]) =>
      AppLogger.error(message, error, stackTrace, 'UserProvider');
  void logSuccess(String message) => AppLogger.success(message, 'UserProvider');
  void logDatabase(String message) => AppLogger.database(message, 'UserProvider');
}