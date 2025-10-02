import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

/// Clean data provider that manages user-generated content only
/// No dummy data - all content created by real users
class DatabaseProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Expose database service for testing
  DatabaseService get db => _db;

  // User data
  Map<String, dynamic>? _currentUserProfile;
  final List<Map<String, dynamic>> _users = [];
  bool _isCurrentUserLoading = false;

  // Restaurant data
  List<Map<String, dynamic>> _restaurants = [];
  bool _isRestaurantsLoading = false;

  // Session data
  List<Map<String, dynamic>> _openSessions = [];
  List<Map<String, dynamic>> _userSessions = [];
  final List<Map<String, dynamic>> _joinedSessions = [];
  final List<Map<String, dynamic>> _pendingRequests = [];
  bool _isSessionsLoading = false;

  // Social data
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _userPosts = [];
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _notifications = [];
  final List<Map<String, dynamic>> _reviews = [];
  bool _isPostsLoading = false;
  bool _isConversationsLoading = false;
  bool _isNotificationsLoading = false;

  // App configuration
  List<String> _foodPreferences = [];
  List<String> _dietaryRestrictions = [];
  bool _isConfigLoading = false;

  // Loading states
  bool _isInitialized = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;
  List<Map<String, dynamic>> get users => _users;
  List<Map<String, dynamic>> get restaurants => _restaurants;
  List<Map<String, dynamic>> get openSessions => _openSessions;
  List<Map<String, dynamic>> get userSessions => _userSessions;
  List<Map<String, dynamic>> get joinedSessions => _joinedSessions;
  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;
  List<Map<String, dynamic>> get posts => _posts;
  List<Map<String, dynamic>> get userPosts => _userPosts;
  List<Map<String, dynamic>> get conversations => _conversations;
  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get reviews => _reviews;
  List<String> get foodPreferences => _foodPreferences;
  List<String> get dietaryRestrictions => _dietaryRestrictions;

  // Loading state getters
  bool get isInitialized => _isInitialized;
  bool get isCurrentUserLoading => _isCurrentUserLoading;
  bool get isRestaurantsLoading => _isRestaurantsLoading;
  bool get isSessionsLoading => _isSessionsLoading;
  bool get isPostsLoading => _isPostsLoading;
  bool get isConversationsLoading => _isConversationsLoading;
  bool get isNotificationsLoading => _isNotificationsLoading;
  bool get isConfigLoading => _isConfigLoading;
  String? get error => _error;

  // Current user helper
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  /// Initialize the database provider
  Future<void> initialize() async {
    try {
      _error = null;

      if (!isAuthenticated) {
        if (kDebugMode) debugPrint('User not authenticated, skipping initialization');
        return;
      }

      // Load initial data (user-generated content only)
      await _loadInitialData();

      _isInitialized = true;
      notifyListeners();

      if (kDebugMode) debugPrint('DatabaseProvider initialized successfully');
    } catch (e) {
      _error = 'Failed to initialize database: $e';
      if (kDebugMode) debugPrint('Error initializing DatabaseProvider: $e');
      notifyListeners();
    }
  }


  /// Load initial data when app starts
  Future<void> _loadInitialData() async {
    try {
      // Load data in parallel for better performance
      await Future.wait([
        loadCurrentUserProfile(),
        loadRestaurants(),
        loadAppConfiguration(),
        loadFeedPosts(),
      ]);

      // Load user-specific data after user profile is loaded
      if (_currentUserProfile != null) {
        await Future.wait([
          loadOpenSessions(),
          loadUserSessions(),
          loadConversations(),
          loadUsers(),
        ]);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading initial data: $e');
      rethrow;
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Load current user profile
  Future<void> loadCurrentUserProfile() async {
    if (!isAuthenticated) return;

    try {
      _isCurrentUserLoading = true;
      notifyListeners();

      _currentUserProfile = await _db.getCurrentUserProfile();

      _isCurrentUserLoading = false;
      notifyListeners();
    } catch (e) {
      _isCurrentUserLoading = false;
      if (kDebugMode) debugPrint('Error loading current user profile: $e');
      notifyListeners();
    }
  }

  /// Load all users for search functionality
  Future<void> loadUsers() async {
    try {
      // Load a sample of users for search functionality
      // In a real app, this might be paginated or limited
      _users.clear();
      final searchResults = await _db.searchUsers(''); // Empty query to get all users
      _users.addAll(searchResults);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading users: $e');
    }
  }

  /// Create user profile
  Future<void> createUserProfile({
    required String email,
    required String displayName,
    String? username,
    String? profilePicture,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      await _db.createUserProfile(
        uid: currentUserId!,
        email: email,
        displayName: displayName,
        username: username,
        profilePicture: profilePicture,
      );

      await loadCurrentUserProfile();
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      await _db.updateUserProfile(currentUserId!, data);
      await loadCurrentUserProfile();
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }


  // ==================== RESTAURANT MANAGEMENT ====================

  /// Load restaurants
  Future<void> loadRestaurants() async {
    try {
      _isRestaurantsLoading = true;
      notifyListeners();

      _restaurants = await _db.getRestaurants();

      _isRestaurantsLoading = false;
      notifyListeners();
    } catch (e) {
      _isRestaurantsLoading = false;
      if (kDebugMode) debugPrint('Error loading restaurants: $e');
      notifyListeners();
    }
  }

  /// Get restaurant by ID
  Future<Map<String, dynamic>?> getRestaurant(String restaurantId) async {
    try {
      return await _db.getRestaurant(restaurantId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting restaurant: $e');
      return null;
    }
  }

  /// Search restaurants
  Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
    try {
      return await _db.searchRestaurants(query);
    } catch (e) {
      if (kDebugMode) debugPrint('Error searching restaurants: $e');
      return [];
    }
  }

  // ==================== MEAL SESSION MANAGEMENT ====================

  /// Load open meal sessions (excludes user's own sessions for discovery)
  Future<void> loadOpenSessions({bool forceRefresh = false}) async {
    try {
      _isSessionsLoading = true;
      _error = null;
      notifyListeners();

      final allSessions = await _db.getOpenMealSessions();

      // Filter out user's own sessions for discovery
      final filteredSessions = allSessions.where((session) {
        final hostUserId = session['hostUserId'] as String?;
        return hostUserId != currentUserId; // Exclude user's own sessions
      }).toList();

      if (kDebugMode) {
        debugPrint('🔍 DatabaseProvider: Loaded ${allSessions.length} total sessions, ${filteredSessions.length} available for discovery (excluding own sessions)');
        debugPrint('👤 Current user ID: $currentUserId');

        if (allSessions.isNotEmpty) {
          debugPrint('📋 Sessions after time filter (future only):');
          for (int i = 0; i < allSessions.length; i++) {
            final session = allSessions[i];
            final isOwn = session['hostUserId'] == currentUserId;
            final scheduledTime = session['scheduledTime'] as Timestamp?;
            debugPrint('  ${i + 1}. ${session['title']} - Host: ${session['hostUserId']} ${isOwn ? '[OWN]' : '[OTHER]'} - Time: ${scheduledTime?.toDate()}');
          }

          debugPrint('📋 Sessions available for discovery (excluding own):');
          for (int i = 0; i < filteredSessions.length; i++) {
            final session = filteredSessions[i];
            debugPrint('  ${i + 1}. ${session['title']} - Host: ${session['hostUserId']}');
          }
        }
      }

      // Always update data to ensure fresh results
      _openSessions = filteredSessions;

      _isSessionsLoading = false;
      notifyListeners();
    } catch (e) {
      _isSessionsLoading = false;
      _error = 'Failed to load sessions: $e';
      if (kDebugMode) debugPrint('Error loading open sessions: $e');
      notifyListeners();
    }
  }

  /// Load user's meal sessions
  Future<void> loadUserSessions() async {
    if (!isAuthenticated) return;

    try {
      if (kDebugMode) debugPrint('🔍 Loading user sessions for user: $currentUserId');
      final sessions = await _db.getUserMealSessions(currentUserId!);
      if (kDebugMode) debugPrint('📝 Found ${sessions.length} user sessions: ${sessions.map((s) => s['id']).toList()}');

      // Always update the cache with the latest data from database
      _userSessions = sessions;
      if (kDebugMode) debugPrint('✅ Updated _userSessions with ${_userSessions.length} sessions');

      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error loading user sessions: $e');
    }
  }

  /// Force refresh all session data
  Future<void> refreshSessionData() async {
    if (kDebugMode) debugPrint('🔄 Force refreshing all session data...');

    _openSessions.clear();
    _userSessions.clear();
    _joinedSessions.clear();

    await Future.wait([
      loadOpenSessions(forceRefresh: true),
      loadUserSessions(),
    ]);

    if (kDebugMode) {
      debugPrint('✅ Session data refreshed. Open: ${_openSessions.length}, User: ${_userSessions.length}');
    }
  }

  /// Create meal session
  Future<String> createMealSession(Map<String, dynamic> sessionData) async {
    try {
      if (kDebugMode) debugPrint('🚀 Creating meal session for user: $currentUserId');
      if (kDebugMode) debugPrint('📋 Session data: ${sessionData.keys.toList()}');

      final sessionId = await _db.createMealSession(sessionData);
      if (kDebugMode) debugPrint('✅ Session created with ID: $sessionId');

      if (kDebugMode) debugPrint('🔄 Clearing cache and refreshing sessions data...');
      // Clear cache to force fresh data load
      _userSessions.clear();
      _openSessions.clear();

      await loadOpenSessions();
      await loadUserSessions();
      if (kDebugMode) debugPrint('🏁 Session creation complete. User has ${_userSessions.length} sessions');

      return sessionId;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error creating meal session: $e');
      rethrow;
    }
  }

  /// Join meal session
  Future<void> joinMealSession(String sessionId) async {
    try {
      await _db.joinMealSession(sessionId);
      await loadOpenSessions();
    } catch (e) {
      if (kDebugMode) debugPrint('Error joining meal session: $e');
      rethrow;
    }
  }

  /// Accept join request
  Future<void> acceptJoinRequest(String sessionId, String userId) async {
    try {
      await _db.acceptJoinRequest(sessionId, userId);
      await loadUserSessions();
    } catch (e) {
      if (kDebugMode) debugPrint('Error accepting join request: $e');
      rethrow;
    }
  }

  /// Reject join request
  Future<void> rejectJoinRequest(String sessionId, String userId) async {
    try {
      await _db.rejectJoinRequest(sessionId, userId);
      await loadUserSessions();
    } catch (e) {
      if (kDebugMode) debugPrint('Error rejecting join request: $e');
      rethrow;
    }
  }

  // ==================== SOCIAL FEATURES ====================

  /// Load feed posts
  Future<void> loadFeedPosts() async {
    try {
      _isPostsLoading = true;
      notifyListeners();

      _posts = await _db.getFeedPosts();

      _isPostsLoading = false;
      notifyListeners();
    } catch (e) {
      _isPostsLoading = false;
      if (kDebugMode) debugPrint('Error loading feed posts: $e');
      notifyListeners();
    }
  }

  /// Load user posts
  Future<void> loadUserPosts(String userId) async {
    try {
      _userPosts = await _db.getUserPosts(userId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading user posts: $e');
    }
  }

  /// Create post
  Future<String> createPost(Map<String, dynamic> postData) async {
    try {
      final postId = await _db.createPost(postData);
      await loadFeedPosts();
      if (currentUserId != null) {
        await loadUserPosts(currentUserId!);
      }
      return postId;
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  /// Toggle post like
  Future<void> togglePostLike(String postId) async {
    try {
      await _db.toggleLike(postId);
      await loadFeedPosts();
    } catch (e) {
      if (kDebugMode) debugPrint('Error toggling post like: $e');
      rethrow;
    }
  }

  /// Check if post is liked
  Future<bool> isPostLiked(String postId) async {
    try {
      return await _db.isPostLiked(postId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking post like: $e');
      return false;
    }
  }

  // ==================== FOLLOW SYSTEM ====================

  /// Follow user
  Future<void> followUser(String userId) async {
    try {
      await _db.followUser(userId);

      // Check if they became mutual follows and activate pending messages
      final areMutual = await areMutualFollows(userId);
      if (areMutual) {
        await _db.activatePendingMessages(userId);
      }

      // Update current user profile to reflect new following count
      await loadCurrentUserProfile();

      // Update the cached user in the users list to reflect new follower count
      final userIndex = _users.indexWhere((user) => user['id'] == userId);
      if (userIndex != -1) {
        _users[userIndex] = {
          ..._users[userIndex],
          'followersCount': (_users[userIndex]['followersCount'] ?? 0) + 1,
        };
      }

      notifyListeners();

      if (kDebugMode) debugPrint('✅ Successfully followed user and updated UI');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error following user: $e');
      rethrow;
    }
  }

  /// Unfollow user
  Future<void> unfollowUser(String userId) async {
    try {
      await _db.unfollowUser(userId);

      // Update current user profile to reflect new following count
      await loadCurrentUserProfile();

      // Update the cached user in the users list to reflect new follower count
      final userIndex = _users.indexWhere((user) => user['id'] == userId);
      if (userIndex != -1) {
        _users[userIndex] = {
          ..._users[userIndex],
          'followersCount': math.max(0, (_users[userIndex]['followersCount'] ?? 0) - 1),
        };
      }

      notifyListeners();

      if (kDebugMode) debugPrint('✅ Successfully unfollowed user and updated UI');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error unfollowing user: $e');
      rethrow;
    }
  }

  /// Search users by name/username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return _users; // Return loaded users if no query
      }
      return await _db.searchUsers(query);
    } catch (e) {
      if (kDebugMode) debugPrint('Error searching users: $e');
      return [];
    }
  }

  /// Check if following user
  Future<bool> isFollowing(String userId) async {
    try {
      return await _db.isFollowing(userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking follow status: $e');
      return false;
    }
  }

  /// Get list of users that the current user is following
  Future<List<Map<String, dynamic>>> getFollowing({String? userId}) async {
    try {
      return await _db.getFollowing(userId: userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting following list: $e');
      return [];
    }
  }

  /// Get list of users that follow the specified user
  Future<List<Map<String, dynamic>>> getFollowers({String? userId}) async {
    try {
      return await _db.getFollowers(userId: userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting followers list: $e');
      return [];
    }
  }

  /// Get follow statistics for a user
  Future<Map<String, int>> getFollowStats({String? userId}) async {
    try {
      return await _db.getFollowStats(userId: userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting follow stats: $e');
      return {'followersCount': 0, 'followingCount': 0};
    }
  }

  /// Check if two users are mutual follows
  Future<bool> areMutualFollows(String userId) async {
    try {
      return await _db.areMutualFollows(userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking mutual follows: $e');
      return false;
    }
  }

  // ==================== MESSAGING SYSTEM ====================

  /// Send a message to another user
  Future<void> sendMessage(String recipientId, String content, {bool isPending = false}) async {
    try {
      await _db.sendMessage(recipientId, content, isPending: isPending);

      // Check if they became mutual follows and activate pending messages
      final areMutual = await areMutualFollows(recipientId);
      if (areMutual) {
        await _db.activatePendingMessages(recipientId);
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  /// Get pending message count between current user and another user
  Future<int> getPendingMessageCount(String userId) async {
    try {
      return await _db.getPendingMessageCount(userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting pending message count: $e');
      return 0;
    }
  }

  /// Get messages between two users
  Future<List<Map<String, dynamic>>> getMessages(String userId) async {
    try {
      return await _db.getMessages(userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting messages: $e');
      return [];
    }
  }

  // ==================== NOTIFICATION SYSTEM ====================

  /// Load notifications
  Future<void> loadNotifications() async {
    try {
      _isNotificationsLoading = true;
      notifyListeners();

      _notifications = await _db.getNotifications();

      _isNotificationsLoading = false;
      notifyListeners();
    } catch (e) {
      _isNotificationsLoading = false;
      if (kDebugMode) debugPrint('Error loading notifications: $e');
      notifyListeners();
    }
  }

  /// Create a notification
  Future<void> createNotification({
    required String recipientId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _db.createNotification(
        recipientId: recipientId,
        type: type,
        title: title,
        message: message,
        data: data,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating notification: $e');
      rethrow;
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.markNotificationAsRead(notificationId);
      await loadNotifications(); // Refresh notifications
    } catch (e) {
      if (kDebugMode) debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _db.markAllNotificationsAsRead();
      await loadNotifications(); // Refresh notifications
    } catch (e) {
      if (kDebugMode) debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // ==================== CONVERSATIONS & MESSAGES ====================

  /// Load conversations
  Future<void> loadConversations() async {
    try {
      _isConversationsLoading = true;
      notifyListeners();

      // Note: You'll need to implement this in DatabaseService
      _conversations = [];

      _isConversationsLoading = false;
      notifyListeners();
    } catch (e) {
      _isConversationsLoading = false;
      if (kDebugMode) debugPrint('Error loading conversations: $e');
      notifyListeners();
    }
  }

  // ==================== APP CONFIGURATION ====================

  /// Load app configuration
  Future<void> loadAppConfiguration() async {
    try {
      _isConfigLoading = true;
      notifyListeners();

      final results = await Future.wait([
        _db.getAppConfig('food_preferences'),
        _db.getAppConfig('dietary_restrictions'),
      ]);

      _foodPreferences = results[0];
      _dietaryRestrictions = results[1];

      _isConfigLoading = false;
      notifyListeners();
    } catch (e) {
      _isConfigLoading = false;
      if (kDebugMode) debugPrint('Error loading app configuration: $e');
      notifyListeners();
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Refresh all data
  Future<void> refreshAllData() async {
    try {
      await _loadInitialData();
    } catch (e) {
      _error = 'Failed to refresh data: $e';
      if (kDebugMode) debugPrint('Error refreshing data: $e');
      notifyListeners();
    }
  }

  /// Clear all cached data
  void clearCache() {
    _currentUserProfile = null;
    _users.clear();
    _restaurants.clear();
    _openSessions.clear();
    _userSessions.clear();
    _joinedSessions.clear();
    _pendingRequests.clear();
    _posts.clear();
    _userPosts.clear();
    _conversations.clear();
    _foodPreferences.clear();
    _dietaryRestrictions.clear();
    _isInitialized = false;
    _error = null;
    notifyListeners();
  }

  /// Update online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      await _db.updateOnlineStatus(isOnline);
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating online status: $e');
    }
  }

  /// Clear social feed data (keeps restaurants and users)
  Future<void> clearSocialFeedData() async {
    try {
      if (kDebugMode) debugPrint('🧹 DatabaseProvider: Starting to clear social feed data...');

      await _db.clearSocialFeedData();

      // Clear local cache
      _posts.clear();
      _userPosts.clear();
      _conversations.clear();
      _notifications.clear();

      // Reset user social counts in local cache
      for (final user in _users) {
        user['followersCount'] = 0;
        user['followingCount'] = 0;
        user['postsCount'] = 0;
      }

      notifyListeners();
      if (kDebugMode) debugPrint('✅ DatabaseProvider: Social feed data cleared and cache refreshed');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ DatabaseProvider: Error clearing social feed data: $e');
      rethrow;
    }
  }


  /// Add comment to a post
  Future<String> addPostComment(String postId, String comment) async {
    try {
      final commentId = await _db.addComment(postId, comment);
      // Refresh posts to get updated comment count
      await loadFeedPosts();
      return commentId;
    } catch (e) {
      _error = 'Failed to add comment: $e';
      if (kDebugMode) debugPrint('Error adding comment: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Get comments for a post
  Future<List<Map<String, dynamic>>> getPostComments(String postId) async {
    try {
      return await _db.getPostComments(postId);
    } catch (e) {
      _error = 'Failed to load comments: $e';
      if (kDebugMode) debugPrint('Error loading comments: $e');
      notifyListeners();
      return [];
    }
  }

  /// Sign out and clear data
  Future<void> signOut() async {
    try {
      await updateOnlineStatus(false);
      clearCache();
    } catch (e) {
      if (kDebugMode) debugPrint('Error during sign out: $e');
    }
  }

  @override
  void dispose() {
    // Clean up any streams or listeners here
    super.dispose();
  }
}