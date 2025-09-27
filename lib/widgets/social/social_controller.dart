import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class SocialController extends ChangeNotifier {
  // Posts state
  List<Map<String, dynamic>> _posts = [];
  bool _isLoadingPosts = false;

  // Messages state
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoadingConversations = false;
  int _unreadCount = 0;

  // Search state
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';

  // Profile state
  Map<String, dynamic> _userProfile = {};
  bool _isLoadingProfile = false;

  // Getters
  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoadingPosts => _isLoadingPosts;

  List<Map<String, dynamic>> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  int get unreadCount => _unreadCount;

  List<Map<String, dynamic>> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  Map<String, dynamic> get userProfile => _userProfile;
  bool get isLoadingProfile => _isLoadingProfile;

  // Posts methods
  Future<void> loadPosts() async {
    _isLoadingPosts = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _posts = List.from(DummyData.posts);
      _isLoadingPosts = false;
      notifyListeners();
    } catch (e) {
      _isLoadingPosts = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }

  void likePost(String postId) {
    final postIndex = _posts.indexWhere((post) => post['id'] == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final isCurrentlyLiked = post['isLikedByCurrentUser'] ?? false;

      _posts[postIndex] = {
        ..._posts[postIndex],
        'isLikedByCurrentUser': !isCurrentlyLiked,
        'likesCount': (post['likesCount'] ?? 0) + (!isCurrentlyLiked ? 1 : -1),
      };

      notifyListeners();
    }
  }

  void sharePost(String postId) {
    final postIndex = _posts.indexWhere((post) => post['id'] == postId);
    if (postIndex != -1) {
      _posts[postIndex] = {
        ..._posts[postIndex],
        'sharesCount': (_posts[postIndex]['sharesCount'] ?? 0) + 1,
      };

      notifyListeners();
    }
  }

  Future<void> createPost({
    required String caption,
    String? imageUrl,
    String? location,
    String? restaurantId,
    List<String>? hashtags,
  }) async {
    final newPost = {
      'id': 'post_${DateTime.now().millisecondsSinceEpoch}',
      'userId': CurrentUser.userId,
      'caption': caption,
      'imageUrl': imageUrl,
      'location': location,
      'restaurantId': restaurantId,
      'hashtags': hashtags ?? [],
      'timestamp': DateTime.now().toIso8601String(),
      'likesCount': 0,
      'commentsCount': 0,
      'sharesCount': 0,
      'isLikedByCurrentUser': false,
    };

    _posts.insert(0, newPost);
    notifyListeners();
  }

  // Messages methods
  Future<void> loadConversations() async {
    _isLoadingConversations = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      _conversations = DummyData.getConversationsForUser(CurrentUser.userId);
      _updateUnreadCount();
      _isLoadingConversations = false;
      notifyListeners();
    } catch (e) {
      _isLoadingConversations = false;
      notifyListeners();
      rethrow;
    }
  }

  void _updateUnreadCount() {
    _unreadCount = _conversations.fold<int>(
      0,
      (sum, conv) => sum + (conv['unreadCount'] as int? ?? 0),
    );
  }

  void markConversationAsRead(String conversationId) {
    final convIndex = _conversations.indexWhere((conv) => conv['id'] == conversationId);
    if (convIndex != -1) {
      _conversations[convIndex] = {
        ..._conversations[convIndex],
        'unreadCount': 0,
      };
      _updateUnreadCount();
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getConversationsByType(String type) {
    return _conversations.where((conv) => conv['type'] == type).toList();
  }

  // Search methods
  Future<void> performSearch(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchQuery = query;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 400));

      List<Map<String, dynamic>> results = [];

      // Search users
      final users = DummyData.searchUsers(query);
      for (var user in users) {
        results.add({
          'type': 'user',
          'data': user,
        });
      }

      // Search posts
      final posts = DummyData.posts.where((post) {
        final caption = post['caption']?.toString().toLowerCase() ?? '';
        final hashtags = (post['hashtags'] as List?)?.join(' ').toLowerCase() ?? '';
        return caption.contains(query.toLowerCase()) ||
               hashtags.contains(query.toLowerCase());
      }).toList();

      for (var post in posts) {
        results.add({
          'type': 'post',
          'data': post,
        });
      }

      // Search restaurants
      final restaurants = DummyData.restaurants.where((restaurant) {
        final name = restaurant['name']?.toString().toLowerCase() ?? '';
        final cuisine = restaurant['cuisine']?.toString().toLowerCase() ?? '';
        return name.contains(query.toLowerCase()) ||
               cuisine.contains(query.toLowerCase());
      }).toList();

      for (var restaurant in restaurants) {
        results.add({
          'type': 'restaurant',
          'data': restaurant,
        });
      }

      _searchResults = results;
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _isSearching = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> getSearchResultsByType(String type) {
    if (type.toLowerCase() == 'all') return _searchResults;
    return _searchResults.where((result) => result['type'] == type.toLowerCase()).toList();
  }

  // Profile methods
  Future<void> loadUserProfile() async {
    _isLoadingProfile = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _userProfile = CurrentUser.currentUserData;
      _isLoadingProfile = false;
      notifyListeners();
    } catch (e) {
      _isLoadingProfile = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? username,
    String? email,
    String? bio,
    String? location,
    List<String>? foodPreferences,
    List<String>? interests,
  }) async {
    final updatedProfile = {
      ..._userProfile,
      if (name != null) 'name': name,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (foodPreferences != null) 'foodPreferences': foodPreferences,
      if (interests != null) 'interests': interests,
    };

    _userProfile = updatedProfile;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  List<Map<String, dynamic>> getUserPosts() {
    return _posts.where((post) => post['userId'] == CurrentUser.userId).toList();
  }

  List<Map<String, dynamic>> getUserReviews() {
    return DummyData.getReviewsForUser(CurrentUser.userId);
  }

  // Social stats
  Map<String, int> getSocialStats() {
    final userPosts = getUserPosts();
    final followers = _userProfile['followersCount'] ?? 0;
    final following = _userProfile['followingCount'] ?? 0;

    return {
      'posts': userPosts.length,
      'followers': followers,
      'following': following,
      'unreadMessages': _unreadCount,
    };
  }

  // Follow/Unfollow user
  Future<void> toggleFollowUser(String userId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // This would update the follow status in a real implementation
    notifyListeners();
  }

  // Utility methods
  void reset() {
    _posts = [];
    _conversations = [];
    _searchResults = [];
    _userProfile = {};
    _unreadCount = 0;
    _isLoadingPosts = false;
    _isLoadingConversations = false;
    _isSearching = false;
    _isLoadingProfile = false;
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> initialize() async {
    await Future.wait([
      loadPosts(),
      loadConversations(),
      loadUserProfile(),
    ]);
  }
}