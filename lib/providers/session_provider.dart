import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/database_service.dart';
import '../utils/logger.dart';
import '../constants/app_constants.dart';
import '../constants/session_constants.dart';

/// Provider responsible for meal session management
class SessionProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Session data
  List<Map<String, dynamic>> _openSessions = [];
  List<Map<String, dynamic>> _userSessions = [];
  final List<Map<String, dynamic>> _joinedSessions = [];
  final List<Map<String, dynamic>> _pendingRequests = [];

  // Session relationship tracking
  final Map<String, SessionUserRelation> _userSessionRelations = {};

  // Loading states
  bool _isSessionsLoading = false;
  String? _error;
  DateTime? _lastOpenSessionsLoad;
  DateTime? _lastUserSessionsLoad;

  // Getters
  List<Map<String, dynamic>> get openSessions => List.unmodifiable(_openSessions);
  List<Map<String, dynamic>> get userSessions => List.unmodifiable(_userSessions);
  List<Map<String, dynamic>> get joinedSessions => List.unmodifiable(_joinedSessions);
  List<Map<String, dynamic>> get pendingRequests => List.unmodifiable(_pendingRequests);
  bool get isSessionsLoading => _isSessionsLoading;
  String? get error => _error;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if open sessions need refresh
  bool get openSessionsNeedRefresh {
    if (_lastOpenSessionsLoad == null) return true;
    return DateTime.now().difference(_lastOpenSessionsLoad!) > AppConstants.shortCacheDuration;
  }

  /// Check if user sessions need refresh
  bool get userSessionsNeedRefresh {
    if (_lastUserSessionsLoad == null) return true;
    return DateTime.now().difference(_lastUserSessionsLoad!) > AppConstants.defaultCacheDuration;
  }

  /// Load open meal sessions with intelligent caching (excludes user's own sessions)
  Future<void> loadOpenSessions({bool forceRefresh = false}) async {
    if (!forceRefresh && !openSessionsNeedRefresh && _openSessions.isNotEmpty) {
      logDebug('Using cached open sessions data');
      return;
    }

    try {
      _isSessionsLoading = true;
      _error = null;
      notifyListeners();

      logDatabase('Loading open sessions${forceRefresh ? ' (forced refresh)' : ''}');

      final allSessions = await _db.getOpenMealSessions();

      // Filter out user's own sessions and update relationship tracking
      _openSessions = allSessions.where((session) {
        final sessionId = session['id'] as String;
        final hostUserId = session['hostUserId'] as String?;

        // Exclude user's own sessions
        if (hostUserId == currentUserId) {
          _userSessionRelations[sessionId] = SessionUserRelation.host;
          return false;
        }

        // Update relationship tracking for other sessions
        _updateSessionRelationship(session);
        return true;
      }).toList();

      _lastOpenSessionsLoad = DateTime.now();

      logSuccess('Loaded ${_openSessions.length} open sessions (excluding own sessions)');

      _isSessionsLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Failed to load open sessions';
      _isSessionsLoading = false;
      logError('Error loading open sessions', e, stackTrace);
      notifyListeners();
    }
  }

  /// Load user's meal sessions
  Future<void> loadUserSessions({bool forceRefresh = false}) async {
    if (!isAuthenticated) return;

    if (!forceRefresh && !userSessionsNeedRefresh && _userSessions.isNotEmpty) {
      logDebug('Using cached user sessions data');
      return;
    }

    try {
      logDatabase('Loading user sessions for: $currentUserId${forceRefresh ? ' (forced refresh)' : ''}');

      final sessions = await _db.getUserMealSessions(currentUserId!);
      _userSessions = sessions;
      _lastUserSessionsLoad = DateTime.now();

      logSuccess('Loaded ${_userSessions.length} user sessions');

      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Failed to load user sessions';
      logError('Error loading user sessions', e, stackTrace);
      notifyListeners();
    }
  }

  /// Create meal session
  Future<String> createMealSession(Map<String, dynamic> sessionData) async {
    try {
      logDatabase('Creating meal session for user: $currentUserId');

      final sessionId = await _db.createMealSession(sessionData);
      logSuccess('Session created with ID: $sessionId');

      // Refresh both open and user sessions
      await Future.wait([
        loadOpenSessions(forceRefresh: true),
        loadUserSessions(forceRefresh: true),
      ]);

      logSuccess('Session creation complete. User has ${_userSessions.length} sessions');

      return sessionId;
    } catch (e, stackTrace) {
      _error = 'Failed to create meal session';
      logError('Error creating meal session', e, stackTrace);
      rethrow;
    }
  }

  /// Join meal session
  Future<void> joinMealSession(String sessionId) async {
    try {
      logDatabase('Joining session: $sessionId');

      await _db.joinMealSession(sessionId);

      // Refresh sessions to reflect the change
      await Future.wait([
        loadOpenSessions(forceRefresh: true),
        loadJoinedSessions(forceRefresh: true),
      ]);

      logSuccess('Successfully joined session');
    } catch (e, stackTrace) {
      _error = 'Failed to join meal session';
      logError('Error joining meal session', e, stackTrace);
      rethrow;
    }
  }

  /// Leave meal session
  Future<void> leaveMealSession(String sessionId) async {
    try {
      logDatabase('Leaving session: $sessionId');

      await _db.leaveMealSession(sessionId);

      // Refresh sessions to reflect the change
      await Future.wait([
        loadOpenSessions(forceRefresh: true),
        loadJoinedSessions(forceRefresh: true),
      ]);

      logSuccess('Successfully left session');
    } catch (e, stackTrace) {
      _error = 'Failed to leave meal session';
      logError('Error leaving meal session', e, stackTrace);
      rethrow;
    }
  }

  /// Load joined sessions
  Future<void> loadJoinedSessions({bool forceRefresh = false}) async {
    if (!isAuthenticated) return;

    try {
      logDatabase('Loading joined sessions');

      final sessions = await _db.getJoinedMealSessions(currentUserId!);
      _joinedSessions.clear();
      _joinedSessions.addAll(sessions);

      logSuccess('Loaded ${_joinedSessions.length} joined sessions');

      notifyListeners();
    } catch (e, stackTrace) {
      logError('Error loading joined sessions', e, stackTrace);
    }
  }

  /// Accept join request
  Future<void> acceptJoinRequest(String sessionId, String userId) async {
    try {
      logDatabase('Accepting join request for session: $sessionId, user: $userId');

      await _db.acceptJoinRequest(sessionId, userId);
      await loadUserSessions(forceRefresh: true);

      logSuccess('Join request accepted');
    } catch (e, stackTrace) {
      _error = 'Failed to accept join request';
      logError('Error accepting join request', e, stackTrace);
      rethrow;
    }
  }

  /// Reject join request
  Future<void> rejectJoinRequest(String sessionId, String userId) async {
    try {
      logDatabase('Rejecting join request for session: $sessionId, user: $userId');

      await _db.rejectJoinRequest(sessionId, userId);
      await loadUserSessions(forceRefresh: true);

      logSuccess('Join request rejected');
    } catch (e, stackTrace) {
      _error = 'Failed to reject join request';
      logError('Error rejecting join request', e, stackTrace);
      rethrow;
    }
  }

  /// Filter sessions by criteria
  List<Map<String, dynamic>> filterSessions(
    List<Map<String, dynamic>> sessions, {
    List<String>? cuisines,
    List<String>? priceRanges,
    int? maxParticipants,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var filtered = sessions;

    if (cuisines != null && cuisines.isNotEmpty) {
      filtered = filtered.where((session) {
        final restaurant = session['restaurant'] as Map<String, dynamic>?;
        final cuisine = restaurant?['cuisine']?.toString().toLowerCase();
        return cuisines.any((c) => cuisine?.contains(c.toLowerCase()) == true);
      }).toList();
    }

    if (priceRanges != null && priceRanges.isNotEmpty) {
      filtered = filtered.where((session) {
        final restaurant = session['restaurant'] as Map<String, dynamic>?;
        final priceRange = restaurant?['priceRange']?.toString();
        return priceRanges.contains(priceRange);
      }).toList();
    }

    if (maxParticipants != null) {
      filtered = filtered.where((session) {
        final currentParticipants = session['currentParticipants'] as int? ?? 0;
        return currentParticipants <= maxParticipants;
      }).toList();
    }

    return filtered;
  }

  /// Get session by ID
  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    try {
      logDatabase('Getting session: $sessionId');

      // Check caches first
      var session = _openSessions.firstWhere(
        (s) => s['id'] == sessionId,
        orElse: () => {},
      );

      if (session.isNotEmpty) {
        logDebug('Returning cached open session');
        return session;
      }

      session = _userSessions.firstWhere(
        (s) => s['id'] == sessionId,
        orElse: () => {},
      );

      if (session.isNotEmpty) {
        logDebug('Returning cached user session');
        return session;
      }

      // Fetch from database
      final sessionData = await _db.getMealSession(sessionId);

      if (sessionData != null) {
        logSuccess('Session loaded from database');
      }

      return sessionData;
    } catch (e, stackTrace) {
      logError('Error getting session', e, stackTrace);
      return null;
    }
  }

  /// Refresh all session data
  Future<void> refresh() async {
    logInfo('Refreshing all session data');

    await Future.wait([
      loadOpenSessions(forceRefresh: true),
      loadUserSessions(forceRefresh: true),
      loadJoinedSessions(forceRefresh: true),
    ]);
  }

  /// Get user's relationship to a specific session
  SessionUserRelation getUserSessionRelation(String sessionId) {
    if (_userSessionRelations.containsKey(sessionId)) {
      return _userSessionRelations[sessionId]!;
    }

    // Determine relationship from cached session data
    final session = _getSessionFromAllCaches(sessionId);
    if (session == null) return SessionUserRelation.none;

    return _determineSessionRelationship(session);
  }

  /// Update session relationship tracking based on session data
  void _updateSessionRelationship(Map<String, dynamic> session) {
    final sessionId = session['id'] as String;
    final relationship = _determineSessionRelationship(session);
    _userSessionRelations[sessionId] = relationship;
  }

  /// Determine user's relationship to a session based on session data
  SessionUserRelation _determineSessionRelationship(Map<String, dynamic> session) {
    final hostUserId = session['hostUserId'] as String?;
    final joinedUserIds = List<String>.from(session['joinedUserIds'] ?? []);
    final pendingUserIds = List<String>.from(session['pendingUserIds'] ?? []);

    if (hostUserId == currentUserId) {
      return SessionUserRelation.host;
    }

    if (joinedUserIds.contains(currentUserId)) {
      return SessionUserRelation.joined;
    }

    if (pendingUserIds.contains(currentUserId)) {
      return SessionUserRelation.pending;
    }

    return SessionUserRelation.none;
  }

  /// Get session from all caches (open, user, joined)
  Map<String, dynamic>? _getSessionFromAllCaches(String sessionId) {
    // Check open sessions
    try {
      return _openSessions.firstWhere((s) => s['id'] == sessionId);
    } catch (e) {
      // Not found in open sessions
    }

    // Check user sessions
    try {
      return _userSessions.firstWhere((s) => s['id'] == sessionId);
    } catch (e) {
      // Not found in user sessions
    }

    // Check joined sessions
    try {
      return _joinedSessions.firstWhere((s) => s['id'] == sessionId);
    } catch (e) {
      // Not found in joined sessions
    }

    return null;
  }

  /// Get pending requests for sessions hosted by current user
  List<Map<String, dynamic>> getHostPendingRequests() {
    final pendingRequests = <Map<String, dynamic>>[];

    for (final session in _userSessions) {
      final pendingUserIds = List<String>.from(session['pendingUserIds'] ?? []);

      for (final userId in pendingUserIds) {
        pendingRequests.add({
          'sessionId': session['id'],
          'userId': userId,
          'sessionTitle': session['title'],
          'restaurantName': session['restaurant']?['name'] ?? 'Unknown Restaurant',
          'scheduledTime': session['scheduledTime'],
          'session': session,
        });
      }
    }

    return pendingRequests;
  }

  /// Get count of pending requests for a specific session
  int getPendingRequestCount(String sessionId) {
    final session = _getSessionFromAllCaches(sessionId);
    if (session == null) return 0;

    final pendingUserIds = List<String>.from(session['pendingUserIds'] ?? []);
    return pendingUserIds.length;
  }

  /// Enhanced join meal session with better workflow
  Future<void> requestToJoinSession(String sessionId) async {
    try {
      logDatabase('Requesting to join session: $sessionId');

      // Validate current relationship
      final currentRelation = getUserSessionRelation(sessionId);
      if (currentRelation != SessionUserRelation.none) {
        throw Exception('Already have a relationship with this session');
      }

      await _db.joinMealSession(sessionId);

      // Update local state immediately
      _userSessionRelations[sessionId] = SessionUserRelation.pending;

      // Refresh sessions to reflect the change
      await Future.wait([
        loadOpenSessions(forceRefresh: true),
        loadJoinedSessions(forceRefresh: true),
      ]);

      logSuccess('Successfully requested to join session');
    } catch (e, stackTrace) {
      _error = 'Failed to request join session';
      logError('Error requesting to join session', e, stackTrace);
      rethrow;
    }
  }

  /// Clear session data (for logout)
  void clearSessionData() {
    logInfo('Clearing session data');

    _openSessions.clear();
    _userSessions.clear();
    _joinedSessions.clear();
    _pendingRequests.clear();
    _userSessionRelations.clear();
    _isSessionsLoading = false;
    _error = null;
    _lastOpenSessionsLoad = null;
    _lastUserSessionsLoad = null;

    notifyListeners();
  }
}

/// Extension to add logging functionality
extension SessionProviderLogging on SessionProvider {
  void logDebug(String message) => AppLogger.debug(message, 'SessionProvider');
  void logInfo(String message) => AppLogger.info(message, 'SessionProvider');
  void logWarning(String message) => AppLogger.warning(message, 'SessionProvider');
  void logError(String message, [Object? error, StackTrace? stackTrace]) =>
      AppLogger.error(message, error, stackTrace, 'SessionProvider');
  void logSuccess(String message) => AppLogger.success(message, 'SessionProvider');
  void logDatabase(String message) => AppLogger.database(message, 'SessionProvider');
}