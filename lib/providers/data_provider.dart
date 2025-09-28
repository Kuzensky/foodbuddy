import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/database_seeder.dart';

class DataProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User data
  Map<String, dynamic>? _currentUserProfile;
  final List<Map<String, dynamic>> _users = [];

  // Restaurant data
  List<Map<String, dynamic>> _restaurants = [];

  // Session data
  List<Map<String, dynamic>> _openSessions = [];
  List<Map<String, dynamic>> _userSessions = [];
  List<Map<String, dynamic>> _joinedSessions = [];
  List<Map<String, dynamic>> _pendingRequests = [];

  // Social data
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _conversations = [];

  // Loading states
  bool _isLoading = false;
  bool _isDatabaseSeeded = false;

  // Getters
  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;
  List<Map<String, dynamic>> get users => _users;
  List<Map<String, dynamic>> get restaurants => _restaurants;
  List<Map<String, dynamic>> get openSessions => _openSessions;
  List<Map<String, dynamic>> get userSessions => _userSessions;
  List<Map<String, dynamic>> get joinedSessions => _joinedSessions;
  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;
  List<Map<String, dynamic>> get posts => _posts;
  List<Map<String, dynamic>> get conversations => _conversations;
  bool get isLoading => _isLoading;
  bool get isDatabaseSeeded => _isDatabaseSeeded;

  // Current user helper
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  /// Initialize the data provider
  Future<void> initialize() async {
    await _loadCurrentUserProfile();
    await _loadRestaurants();
    await _startListeners();
  }

  /// Seed database with sample data
  Future<void> seedDatabase() async {
    if (_isDatabaseSeeded) return;

    _setLoading(true);
    try {
      await DatabaseSeeder.seedDatabase();
      _isDatabaseSeeded = true;

      // Reload data after seeding
      await _loadRestaurants();
      await _startListeners();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Error seeding database: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear database (for testing)
  Future<void> clearDatabase() async {
    _setLoading(true);
    try {
      await DatabaseSeeder.clearDatabase();
      _isDatabaseSeeded = false;

      // Clear local data
      _restaurants.clear();
      _openSessions.clear();
      _userSessions.clear();
      _joinedSessions.clear();
      _pendingRequests.clear();
      _posts.clear();
      _conversations.clear();
      _users.clear();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Error clearing database: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ========== USER MANAGEMENT ==========

  /// Load current user profile
  Future<void> _loadCurrentUserProfile() async {
    if (!isAuthenticated) return;

    try {
      _currentUserProfile = await _firestoreService.getUserProfile(currentUserId!);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading current user profile: $e');
    }
  }

  /// Create user profile
  Future<void> createUserProfile({
    required String name,
    required String email,
    String? username,
    String? bio,
    String? location,
    List<String> foodPreferences = const [],
    List<String> interests = const [],
    int? age,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      await _firestoreService.createUserProfile(
        uid: currentUserId!,
        name: name,
        email: email,
        username: username,
        bio: bio,
        location: location,
        foodPreferences: foodPreferences,
        interests: interests,
        age: age,
      );

      await _loadCurrentUserProfile();
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      await _firestoreService.updateUserProfile(currentUserId!, data);
      await _loadCurrentUserProfile();
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Search users
  Stream<List<Map<String, dynamic>>> searchUsers(String query) {
    return _firestoreService.searchUsers(query);
  }

  // ========== RESTAURANTS ==========

  /// Load restaurants
  Future<void> _loadRestaurants() async {
    try {
      _firestoreService.getRestaurants().listen((restaurants) {
        _restaurants = restaurants;
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading restaurants: $e');
    }
  }

  /// Get restaurant by ID
  Future<Map<String, dynamic>?> getRestaurant(String restaurantId) async {
    return await _firestoreService.getRestaurant(restaurantId);
  }

  /// Get restaurants by cuisine
  Stream<List<Map<String, dynamic>>> getRestaurantsByCuisine(String cuisine) {
    return _firestoreService.getRestaurantsByCuisine(cuisine);
  }

  /// Get nearby restaurants
  Stream<List<Map<String, dynamic>>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) {
    return _firestoreService.getNearbyRestaurants(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }

  // ========== MEAL SESSIONS ==========

  /// Start real-time listeners for session data
  Future<void> _startListeners() async {
    if (!isAuthenticated) return;

    try {
      // Listen to open sessions (discover screen)
      _firestoreService.getOpenMealSessions().listen((sessions) {
        _openSessions = sessions;
        notifyListeners();
      });

      // Listen to user's own sessions
      _firestoreService.getUserMealSessions().listen((sessions) {
        _userSessions = sessions;
        notifyListeners();
      });

      // Listen to joined sessions (matches - active)
      _firestoreService.getJoinedMealSessions().listen((sessions) {
        _joinedSessions = sessions;
        notifyListeners();
      });

      // Listen to pending requests (matches - pending)
      _firestoreService.getPendingJoinRequests().listen((requests) {
        _pendingRequests = requests;
        notifyListeners();
      });

      // Listen to posts feed
      _firestoreService.getPostsFeed().listen((posts) {
        _posts = posts;
        notifyListeners();
      });

      // Listen to conversations
      _firestoreService.getUserConversations().listen((conversations) {
        _conversations = conversations;
        notifyListeners();
      });

    } catch (e) {
      if (kDebugMode) debugPrint('Error starting listeners: $e');
    }
  }

  /// Create meal session
  Future<String> createMealSession({
    required String title,
    required String description,
    required String restaurantId,
    required DateTime scheduledTime,
    required int maxParticipants,
    Map<String, dynamic>? preferences,
    List<String> invitedUsers = const [],
  }) async {
    try {
      final sessionId = await _firestoreService.createMealSession(
        title: title,
        description: description,
        restaurantId: restaurantId,
        scheduledTime: scheduledTime,
        maxParticipants: maxParticipants,
        preferences: preferences,
        invitedUsers: invitedUsers,
      );

      return sessionId;
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating meal session: $e');
      rethrow;
    }
  }

  /// Join meal session
  Future<void> joinMealSession(String sessionId) async {
    try {
      await _firestoreService.joinMealSession(sessionId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error joining meal session: $e');
      rethrow;
    }
  }

  /// Accept join request
  Future<void> acceptJoinRequest(String sessionId, String userId) async {
    try {
      await _firestoreService.acceptJoinRequest(sessionId, userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error accepting join request: $e');
      rethrow;
    }
  }

  /// Reject join request
  Future<void> rejectJoinRequest(String sessionId, String userId) async {
    try {
      await _firestoreService.rejectJoinRequest(sessionId, userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error rejecting join request: $e');
      rethrow;
    }
  }

  // ========== SOCIAL FEATURES ==========

  /// Create post
  Future<String> createPost({
    required String caption,
    String? imageUrl,
    String? location,
    String? restaurantId,
    List<String> hashtags = const [],
  }) async {
    try {
      final postId = await _firestoreService.createPost(
        caption: caption,
        imageUrl: imageUrl,
        location: location,
        restaurantId: restaurantId,
        hashtags: hashtags,
      );

      return postId;
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating post: $e');
      rethrow;
    }
  }

  /// Get user's posts
  Stream<List<Map<String, dynamic>>> getUserPosts(String userId) {
    return _firestoreService.getUserPosts(userId);
  }

  /// Toggle post like
  Future<void> togglePostLike(String postId) async {
    try {
      await _firestoreService.togglePostLike(postId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error toggling post like: $e');
      rethrow;
    }
  }

  // ========== MESSAGING ==========

  /// Create or get conversation
  Future<String> createOrGetConversation(List<String> participants) async {
    try {
      return await _firestoreService.createOrGetConversation(participants);
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating conversation: $e');
      rethrow;
    }
  }

  /// Send message
  Future<void> sendMessage({
    required String conversationId,
    required String receiverId,
    required String text,
    String type = 'text',
  }) async {
    try {
      await _firestoreService.sendMessage(
        conversationId: conversationId,
        receiverId: receiverId,
        text: text,
        type: type,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  /// Get messages for conversation
  Stream<List<Map<String, dynamic>>> getMessages(String conversationId) {
    return _firestoreService.getMessages(conversationId);
  }

  // ========== FOLLOWERS/FOLLOWING ==========

  /// Follow user
  Future<void> followUser(String userIdToFollow) async {
    try {
      await _firestoreService.followUser(userIdToFollow);
    } catch (e) {
      if (kDebugMode) debugPrint('Error following user: $e');
      rethrow;
    }
  }

  /// Unfollow user
  Future<void> unfollowUser(String userIdToUnfollow) async {
    try {
      await _firestoreService.unfollowUser(userIdToUnfollow);
    } catch (e) {
      if (kDebugMode) debugPrint('Error unfollowing user: $e');
      rethrow;
    }
  }

  // ========== HELPER METHODS ==========

  /// Get user by ID from local cache or fetch from Firebase
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    // First check local cache
    try {
      final user = _users.firstWhere((user) => user['uid'] == userId);
      return user;
    } catch (e) {
      // If not in cache, fetch from Firebase
      final user = await _firestoreService.getUserProfile(userId);
      if (user != null) {
        _users.add(user);
        notifyListeners();
      }
      return user;
    }
  }

  /// Get restaurant by ID from local cache
  Map<String, dynamic>? getRestaurantById(String restaurantId) {
    try {
      return _restaurants.firstWhere((restaurant) => restaurant['id'] == restaurantId);
    } catch (e) {
      return null;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Update online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      await _firestoreService.updateOnlineStatus(isOnline);
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating online status: $e');
    }
  }

  /// Sign out and clear data
  void signOut() {
    _currentUserProfile = null;
    _users.clear();
    _openSessions.clear();
    _userSessions.clear();
    _joinedSessions.clear();
    _pendingRequests.clear();
    _posts.clear();
    _conversations.clear();
    notifyListeners();
  }
}