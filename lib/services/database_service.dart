import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Professional database service for FoodBuddy application
/// Handles all Firestore operations with proper error handling and validation
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _restaurants => _firestore.collection('restaurants');
  CollectionReference get _mealSessions => _firestore.collection('meal_sessions');
  CollectionReference get _posts => _firestore.collection('posts');
  CollectionReference get _follows => _firestore.collection('follows');
  CollectionReference get _likes => _firestore.collection('likes');
  CollectionReference get _messages => _firestore.collection('messages');
  CollectionReference get _notifications => _firestore.collection('notifications');
  CollectionReference get _appConfig => _firestore.collection('app_config');

  // Helper getters
  String? get currentUserId => _auth.currentUser?.uid;
  bool get isAuthenticated => _auth.currentUser != null;

  // ==================== USER MANAGEMENT ====================

  /// Create a new user profile
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String? username,
    String? profilePicture,
  }) async {
    try {
      final userData = {
        'id': uid,
        'email': email,
        'displayName': displayName,
        'username': username ?? displayName.toLowerCase().replaceAll(' ', ''),
        'profilePicture': profilePicture,
        'bio': '',
        'age': null,
        'location': '',
        'phoneNumber': '',
        'foodPreferences': <String>[],
        'dietaryRestrictions': <String>[],
        'interests': <String>[],
        'followersCount': 0,
        'followingCount': 0,
        'postsCount': 0,
        'rating': 0.0,
        'reviewCount': 0,
        'isVerified': false,
        'isEmailVerified': false,
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _users.doc(uid).set(userData);
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating user profile: $e');
      throw Exception('Failed to create user profile');
    }
  }

  /// Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _users.doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _users.doc(userId).update(data);
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating user profile: $e');
      throw Exception('Failed to update user profile');
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (currentUserId == null) return null;
    return await getUserProfile(currentUserId!);
  }

  /// Update user online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    if (currentUserId == null) return;

    try {
      await _users.doc(currentUserId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating online status: $e');
    }
  }

  /// Test Firestore connectivity
  Future<bool> testConnection() async {
    try {
      if (kDebugMode) debugPrint('🔄 Testing Firestore connection...');
      final snapshot = await _users.limit(1).get();
      if (kDebugMode) debugPrint('✅ Firestore connection successful! Found ${snapshot.docs.length} documents');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Firestore connection failed: $e');
      return false;
    }
  }

  /// Search users by name or username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        // Return all users if query is empty (for initial load)
        final snapshot = await _users.limit(50).get();
        return snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList();
      }

      final queryLower = query.toLowerCase();

      // Get all users and filter client-side since Firestore has limitations with text search
      final snapshot = await _users.get();
      final results = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final userData = doc.data() as Map<String, dynamic>;
        final name = (userData['name'] ?? userData['displayName'] ?? '').toString().toLowerCase();
        final username = (userData['username'] ?? '').toString().toLowerCase();
        final email = (userData['email'] ?? '').toString().toLowerCase();

        // Check if query matches name, username, or email
        if (name.contains(queryLower) ||
            username.contains(queryLower) ||
            email.contains(queryLower)) {
          results.add({...userData, 'id': doc.id});
        }
      }

      return results;
    } catch (e) {
      if (kDebugMode) debugPrint('Error searching users: $e');
      return [];
    }
  }

  /// Get all users (for discovery/search)
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final snapshot = await _users.limit(100).get();
      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting users: $e');
      return [];
    }
  }

  // ==================== RESTAURANT MANAGEMENT ====================

  /// Create a new restaurant
  Future<String> createRestaurant(Map<String, dynamic> restaurantData) async {
    try {
      restaurantData['createdAt'] = FieldValue.serverTimestamp();
      restaurantData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _restaurants.add(restaurantData);
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating restaurant: $e');
      throw Exception('Failed to create restaurant');
    }
  }

  /// Get all restaurants
  Future<List<Map<String, dynamic>>> getRestaurants() async {
    try {
      // Simplified query to avoid index requirements - filter and sort in code
      final snapshot = await _restaurants
          .where('isActive', isEqualTo: true)
          .get();

      final restaurants = snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();

      // Sort by rating in code instead of in query
      restaurants.sort((a, b) {
        final aRating = (a['rating'] as num?)?.toDouble() ?? 0.0;
        final bRating = (b['rating'] as num?)?.toDouble() ?? 0.0;
        return bRating.compareTo(aRating); // Descending order
      });

      return restaurants;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting restaurants: $e');
      return [];
    }
  }

  /// Get restaurant by ID
  Future<Map<String, dynamic>?> getRestaurant(String restaurantId) async {
    try {
      final doc = await _restaurants.doc(restaurantId).get();
      if (doc.exists) {
        return {...doc.data() as Map<String, dynamic>, 'id': doc.id};
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting restaurant: $e');
      return null;
    }
  }

  /// Search restaurants by name or cuisine
  Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
    try {
      final queryLower = query.toLowerCase();

      final snapshot = await _restaurants
          .where('isActive', isEqualTo: true)
          .get();

      final results = snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .where((restaurant) {
            final name = restaurant['name']?.toString().toLowerCase() ?? '';
            final cuisine = restaurant['cuisine']?.toString().toLowerCase() ?? '';
            return name.contains(queryLower) || cuisine.contains(queryLower);
          })
          .toList();

      return results;
    } catch (e) {
      if (kDebugMode) debugPrint('Error searching restaurants: $e');
      return [];
    }
  }

  // ==================== MEAL SESSION MANAGEMENT ====================

  /// Create a new meal session
  Future<String> createMealSession(Map<String, dynamic> sessionData) async {
    try {
      sessionData['hostUserId'] = currentUserId;
      sessionData['currentParticipants'] = 0;
      sessionData['status'] = 'open';
      sessionData['joinedUserIds'] = <String>[];
      sessionData['pendingUserIds'] = <String>[];
      sessionData['createdAt'] = FieldValue.serverTimestamp();
      sessionData['updatedAt'] = FieldValue.serverTimestamp();

      // If we have a restaurantId, fetch the full restaurant data
      if (sessionData['restaurantId'] != null && sessionData['restaurant'] == null) {
        if (kDebugMode) debugPrint('🍽️ Fetching restaurant data for ID: ${sessionData['restaurantId']}');

        final restaurantData = await getRestaurant(sessionData['restaurantId']);
        if (restaurantData != null) {
          sessionData['restaurant'] = restaurantData;
          if (kDebugMode) debugPrint('✅ Added restaurant data: ${restaurantData['name']}');
        } else {
          if (kDebugMode) debugPrint('⚠️ Could not find restaurant with ID: ${sessionData['restaurantId']}');
        }
      }

      if (kDebugMode) {
        debugPrint('🚀 Creating meal session with data:');
        debugPrint('  Host: $currentUserId');
        debugPrint('  Title: ${sessionData['title']}');
        debugPrint('  Status: ${sessionData['status']}');
        debugPrint('  ScheduledTime: ${sessionData['scheduledTime']}');
        debugPrint('  RestaurantId: ${sessionData['restaurantId']}');
        debugPrint('  Restaurant: ${sessionData['restaurant']?['name'] ?? 'No restaurant data'}');
        debugPrint('  MaxParticipants: ${sessionData['maxParticipants']}');
      }

      final docRef = await _mealSessions.add(sessionData);
      await docRef.update({'id': docRef.id});

      if (kDebugMode) debugPrint('✅ Session created successfully with ID: ${docRef.id}');

      return docRef.id;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error creating meal session: $e');
      throw Exception('Failed to create meal session');
    }
  }

  /// Get open meal sessions (simplified to avoid index requirement)
  Future<List<Map<String, dynamic>>> getOpenMealSessions() async {
    try {
      if (kDebugMode) debugPrint('🔍 Querying open meal sessions...');

      final now = Timestamp.now();
      if (kDebugMode) debugPrint('🕐 Current time: ${now.toDate()}');

      // Simplified query to avoid composite index requirement
      // We'll filter by status only, then filter time and sort in memory
      final snapshot = await _mealSessions
          .where('status', isEqualTo: 'open')
          .limit(100)
          .get();

      if (kDebugMode) {
        debugPrint('📊 Found ${snapshot.docs.length} sessions with status=open');
      }

      // Filter and sort in memory to avoid index requirement
      final sessions = snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .where((session) {
            final scheduledTime = session['scheduledTime'] as Timestamp?;
            if (scheduledTime == null) return false;
            return scheduledTime.compareTo(now) > 0; // Future sessions only
          })
          .toList();

      // Sort by scheduled time
      sessions.sort((a, b) {
        final aTime = a['scheduledTime'] as Timestamp?;
        final bTime = b['scheduledTime'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });

      // Enhance sessions with user profile data
      for (int i = 0; i < sessions.length; i++) {
        final session = sessions[i];
        final hostUserId = session['hostUserId'] as String?;

        if (hostUserId != null) {
          final hostProfile = await getUserProfile(hostUserId);
          if (hostProfile != null) {
            session['hostUser'] = hostProfile;
            if (kDebugMode) {
              debugPrint('✅ Added host profile for session "${session['title']}": ${hostProfile['displayName'] ?? hostProfile['username'] ?? 'No name'}');
            }
          } else {
            if (kDebugMode) {
              debugPrint('⚠️ Could not find user profile for host: $hostUserId');
            }
          }
        }
      }

      if (kDebugMode) {
        debugPrint('✅ After filtering and enriching: ${sessions.length} open sessions with future scheduled time');
        for (int i = 0; i < sessions.length; i++) {
          final session = sessions[i];
          final scheduledTime = session['scheduledTime'] as Timestamp?;
          final hostUser = session['hostUser'] as Map<String, dynamic>?;
          final hostName = hostUser?['displayName'] ?? hostUser?['username'] ?? 'Unknown';
          debugPrint('  ${i + 1}. "${session['title']}" - Host: $hostName (${session['hostUserId']}) - Scheduled: ${scheduledTime?.toDate()}');
        }
      }

      return sessions;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error getting open meal sessions: $e');
      return [];
    }
  }

  /// Get user's meal sessions
  Future<List<Map<String, dynamic>>> getUserMealSessions(String userId) async {
    try {
      if (kDebugMode) debugPrint('🔍 DB Service: Querying user sessions for userId: $userId');

      final snapshot = await _mealSessions
          .where('hostUserId', isEqualTo: userId)
          .get();

      if (kDebugMode) debugPrint('📊 DB Service: Found ${snapshot.docs.length} sessions');

      final sessions = snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();

      // Sort by scheduledTime in application code to avoid index requirements
      sessions.sort((a, b) {
        final aTime = a['scheduledTime'] as Timestamp?;
        final bTime = b['scheduledTime'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime); // Descending order (most recent first)
      });

      if (kDebugMode) debugPrint('✅ DB Service: Returning ${sessions.length} sorted sessions');
      return sessions;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ DB Service: Error getting user meal sessions: $e');
      return [];
    }
  }

  /// Request to join a meal session (enhanced with validation)
  Future<void> joinMealSession(String sessionId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      await _firestore.runTransaction((transaction) async {
        final sessionRef = _mealSessions.doc(sessionId);
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) {
          throw Exception('Session not found');
        }

        final sessionData = sessionDoc.data() as Map<String, dynamic>;

        // Validate session state
        if (sessionData['status'] != 'open') {
          throw Exception('Session is not open for joining');
        }

        if (sessionData['hostUserId'] == currentUserId) {
          throw Exception('Cannot join your own session');
        }

        final joinedUsers = List<String>.from(sessionData['joinedUserIds'] ?? []);
        final pendingUsers = List<String>.from(sessionData['pendingUserIds'] ?? []);

        if (joinedUsers.contains(currentUserId)) {
          throw Exception('Already joined this session');
        }

        if (pendingUsers.contains(currentUserId)) {
          throw Exception('Join request already pending');
        }

        if (joinedUsers.length >= (sessionData['maxParticipants'] ?? 6)) {
          throw Exception('Session is full');
        }

        // Check if session time is in the future with minimum notice
        final scheduledTime = sessionData['scheduledTime'] as Timestamp?;
        if (scheduledTime != null) {
          final sessionDateTime = scheduledTime.toDate();
          final minimumNoticeTime = DateTime.now().add(Duration(hours: 1));
          if (sessionDateTime.isBefore(minimumNoticeTime)) {
            throw Exception('Cannot join session with less than 1 hour notice');
          }
        }

        // Add to pending requests
        pendingUsers.add(currentUserId!);

        transaction.update(sessionRef, {
          'pendingUserIds': pendingUsers,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create notification for host
        final notificationData = {
          'recipientId': sessionData['hostUserId'],
          'senderId': currentUserId,
          'type': 'session_request',
          'title': 'New Join Request',
          'message': 'Someone wants to join your meal session',
          'data': {
            'sessionId': sessionId,
            'sessionTitle': sessionData['title'] ?? 'Meal Session',
            'restaurantName': sessionData['restaurant']?['name'] ?? 'Restaurant',
          },
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        };

        final notificationRef = _notifications.doc();
        transaction.set(notificationRef, {
          ...notificationData,
          'id': notificationRef.id,
        });
      });

      if (kDebugMode) debugPrint('✅ Successfully requested to join session: $sessionId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error requesting to join meal session: $e');
      rethrow;
    }
  }

  /// Accept join request for meal session
  Future<void> acceptJoinRequest(String sessionId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final sessionRef = _mealSessions.doc(sessionId);
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) {
          throw Exception('Session not found');
        }

        final sessionData = sessionDoc.data() as Map<String, dynamic>;

        // Validate host permissions
        if (sessionData['hostUserId'] != currentUserId) {
          throw Exception('Only the host can accept join requests');
        }

        final pendingUsers = List<String>.from(sessionData['pendingUserIds'] ?? []);
        final joinedUsers = List<String>.from(sessionData['joinedUserIds'] ?? []);

        if (!pendingUsers.contains(userId)) {
          throw Exception('No pending request from this user');
        }

        // Check if session would exceed capacity
        final maxParticipants = sessionData['maxParticipants'] as int? ?? 6;
        if (joinedUsers.length >= maxParticipants) {
          throw Exception('Session is already at maximum capacity');
        }

        pendingUsers.remove(userId);
        joinedUsers.add(userId);

        // Update session status if now full
        final newStatus = joinedUsers.length >= maxParticipants ? 'full' : 'open';

        transaction.update(sessionRef, {
          'pendingUserIds': pendingUsers,
          'joinedUserIds': joinedUsers,
          'currentParticipants': joinedUsers.length,
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create acceptance notification
        final notificationData = {
          'recipientId': userId,
          'senderId': currentUserId,
          'type': 'session_accepted',
          'title': 'Join Request Accepted',
          'message': 'Your request to join the meal session was accepted!',
          'data': {
            'sessionId': sessionId,
            'sessionTitle': sessionData['title'] ?? 'Meal Session',
            'restaurantName': sessionData['restaurant']?['name'] ?? 'Restaurant',
            'scheduledTime': sessionData['scheduledTime'],
          },
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        };

        final notificationRef = _notifications.doc();
        transaction.set(notificationRef, {
          ...notificationData,
          'id': notificationRef.id,
        });
      });

      if (kDebugMode) debugPrint('✅ Successfully accepted join request for session: $sessionId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error accepting join request: $e');
      rethrow;
    }
  }

  /// Reject join request for meal session
  Future<void> rejectJoinRequest(String sessionId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final sessionRef = _mealSessions.doc(sessionId);
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) {
          throw Exception('Session not found');
        }

        final sessionData = sessionDoc.data() as Map<String, dynamic>;

        // Validate host permissions
        if (sessionData['hostUserId'] != currentUserId) {
          throw Exception('Only the host can reject join requests');
        }

        final pendingUsers = List<String>.from(sessionData['pendingUserIds'] ?? []);

        if (!pendingUsers.contains(userId)) {
          throw Exception('No pending request from this user');
        }

        pendingUsers.remove(userId);

        transaction.update(sessionRef, {
          'pendingUserIds': pendingUsers,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create rejection notification
        final notificationData = {
          'recipientId': userId,
          'senderId': currentUserId,
          'type': 'session_rejected',
          'title': 'Join Request Declined',
          'message': 'Your request to join the meal session was declined',
          'data': {
            'sessionId': sessionId,
            'sessionTitle': sessionData['title'] ?? 'Meal Session',
            'restaurantName': sessionData['restaurant']?['name'] ?? 'Restaurant',
          },
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        };

        final notificationRef = _notifications.doc();
        transaction.set(notificationRef, {
          ...notificationData,
          'id': notificationRef.id,
        });
      });

      if (kDebugMode) debugPrint('✅ Successfully rejected join request for session: $sessionId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error rejecting join request: $e');
      rethrow;
    }
  }

  /// Leave a meal session
  Future<void> leaveMealSession(String sessionId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      await _firestore.runTransaction((transaction) async {
        final sessionRef = _mealSessions.doc(sessionId);
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) {
          throw Exception('Session not found');
        }

        final sessionData = sessionDoc.data() as Map<String, dynamic>;
        final joinedUsers = List<String>.from(sessionData['joinedUserIds'] ?? []);
        final pendingUsers = List<String>.from(sessionData['pendingUserIds'] ?? []);

        // Remove from joined users if present
        if (joinedUsers.contains(currentUserId)) {
          joinedUsers.remove(currentUserId);
        }

        // Remove from pending users if present
        if (pendingUsers.contains(currentUserId)) {
          pendingUsers.remove(currentUserId);
        }

        transaction.update(sessionRef, {
          'joinedUserIds': joinedUsers,
          'pendingUserIds': pendingUsers,
          'currentParticipants': joinedUsers.length,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // If session was full and someone left, change status back to open
        final maxParticipants = sessionData['maxParticipants'] as int;
        if (sessionData['status'] == 'full' && joinedUsers.length < maxParticipants) {
          transaction.update(sessionRef, {'status': 'open'});
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error leaving meal session: $e');
      throw Exception('Failed to leave meal session');
    }
  }

  /// Get joined meal sessions for a user
  Future<List<Map<String, dynamic>>> getJoinedMealSessions(String userId) async {
    try {
      final snapshot = await _mealSessions
          .where('joinedUserIds', arrayContains: userId)
          .get();

      final sessions = snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();

      // Sort by scheduledTime in application code
      sessions.sort((a, b) {
        final aTime = a['scheduledTime'] as Timestamp?;
        final bTime = b['scheduledTime'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime); // Descending order (most recent first)
      });

      return sessions;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting joined meal sessions: $e');
      return [];
    }
  }

  /// Get a single meal session by ID
  Future<Map<String, dynamic>?> getMealSession(String sessionId) async {
    try {
      final doc = await _mealSessions.doc(sessionId).get();
      if (doc.exists) {
        return {...doc.data() as Map<String, dynamic>, 'id': doc.id};
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting meal session: $e');
      return null;
    }
  }

  /// Debug method: Get ALL sessions (no filters) for troubleshooting
  Future<List<Map<String, dynamic>>> getAllMealSessions() async {
    try {
      if (kDebugMode) debugPrint('🔍 Getting ALL meal sessions for debugging...');

      final snapshot = await _mealSessions.limit(20).get();

      if (kDebugMode) {
        debugPrint('📊 Found ${snapshot.docs.length} total sessions in database');
        for (int i = 0; i < snapshot.docs.length; i++) {
          final sessionData = snapshot.docs[i].data() as Map<String, dynamic>;
          final scheduledTime = sessionData['scheduledTime'] as Timestamp?;
          final status = sessionData['status'] ?? 'no status';
          final title = sessionData['title'] ?? 'no title';
          final hostUserId = sessionData['hostUserId'] ?? 'no host';

          debugPrint('  ${i + 1}. "$title"');
          debugPrint('     Status: $status');
          debugPrint('     Host: $hostUserId');
          debugPrint('     Scheduled: ${scheduledTime?.toDate()}');
          debugPrint('     Created: ${sessionData['createdAt']}');
          debugPrint('     ---');
        }
      }

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error getting all meal sessions: $e');
      return [];
    }
  }

  // ==================== SOCIAL FEATURES ====================

  /// Create a new post
  Future<String> createPost(Map<String, dynamic> postData) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      postData['userId'] = currentUserId;
      postData['likesCount'] = 0;
      postData['commentsCount'] = 0;
      postData['sharesCount'] = 0;
      postData['likedBy'] = [];
      postData['isPublic'] = true;
      postData['createdAt'] = FieldValue.serverTimestamp();
      postData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _posts.add(postData);
      await docRef.update({'id': docRef.id});

      // Update user's post count
      await _users.doc(currentUserId).update({
        'postsCount': FieldValue.increment(1),
      });

      return docRef.id;
    } catch (e) {
      if (kDebugMode) debugPrint('Error creating post: $e');
      throw Exception('Failed to create post');
    }
  }

  /// Get posts for feed (following users + own posts)
  Future<List<Map<String, dynamic>>> getFeedPosts({int limit = 20}) async {
    try {
      // Temporarily remove isPublic filter to avoid composite index requirement
      // All posts are public by default anyway
      final snapshot = await _posts
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting feed posts: $e');
      return [];
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(String postId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final postRef = _posts.doc(postId);
      final postSnapshot = await postRef.get();

      if (!postSnapshot.exists) {
        throw Exception('Post not found');
      }

      final postData = postSnapshot.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(postData['likedBy'] ?? []);
      final isLiked = likedBy.contains(currentUserId);

      if (isLiked) {
        likedBy.remove(currentUserId);
        await postRef.update({
          'likedBy': likedBy,
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        likedBy.add(currentUserId!);
        await postRef.update({
          'likedBy': likedBy,
          'likesCount': FieldValue.increment(1),
        });

        // Create notification for post owner (if not self-like)
        if (postData['userId'] != currentUserId) {
          await createNotification(
            recipientId: postData['userId'],
            type: 'like',
            title: 'New Like',
            message: 'Someone liked your post',
            data: {
              'relatedId': postId,
              'relatedType': 'post',
            },
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error toggling like: $e');
      throw Exception('Failed to toggle like');
    }
  }

  /// Add comment to a post
  Future<String> addComment(String postId, String comment) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final commentData = {
        'id': '',
        'postId': postId,
        'userId': currentUserId,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _posts.doc(postId).collection('comments').add(commentData);
      await docRef.update({'id': docRef.id});

      // Update post's comment count
      await _posts.doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      // Get post data for notification
      final postSnapshot = await _posts.doc(postId).get();
      if (postSnapshot.exists) {
        final postData = postSnapshot.data() as Map<String, dynamic>;

        // Create notification for post owner (if not self-comment)
        if (postData['userId'] != currentUserId) {
          await createNotification(
            recipientId: postData['userId'],
            type: 'comment',
            title: 'New Comment',
            message: 'Someone commented on your post',
            data: {
              'relatedId': postId,
              'relatedType': 'post',
            },
          );
        }
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) debugPrint('Error adding comment: $e');
      throw Exception('Failed to add comment');
    }
  }

  /// Get comments for a post
  Future<List<Map<String, dynamic>>> getPostComments(String postId) async {
    try {
      final snapshot = await _posts
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting post comments: $e');
      return [];
    }
  }

  /// Get user's posts
  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    try {
      final snapshot = await _posts
          .where('userId', isEqualTo: userId)
          .get();

      final posts = snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();

      // Sort by createdAt in memory to avoid composite index requirement
      posts.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime); // Descending order
      });

      return posts;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting user posts: $e');
      return [];
    }
  }

  /// Like/Unlike a post
  Future<void> togglePostLike(String postId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final likeId = '${currentUserId}_$postId';
      final likeRef = _likes.doc(likeId);
      final likeDoc = await likeRef.get();

      await _firestore.runTransaction((transaction) async {
        if (likeDoc.exists) {
          // Unlike
          transaction.delete(likeRef);
          transaction.update(_posts.doc(postId), {
            'likesCount': FieldValue.increment(-1),
          });
        } else {
          // Like
          transaction.set(likeRef, {
            'id': likeId,
            'userId': currentUserId,
            'itemId': postId,
            'itemType': 'post',
            'createdAt': FieldValue.serverTimestamp(),
          });
          transaction.update(_posts.doc(postId), {
            'likesCount': FieldValue.increment(1),
          });
        }
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error toggling post like: $e');
      throw Exception('Failed to toggle post like');
    }
  }

  /// Check if user liked a post
  Future<bool> isPostLiked(String postId) async {
    if (currentUserId == null) return false;

    try {
      final likeId = '${currentUserId}_$postId';
      final doc = await _likes.doc(likeId).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking post like: $e');
      return false;
    }
  }

  // ==================== FOLLOW SYSTEM ====================

  /// Follow a user
  Future<void> followUser(String userId) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    if (currentUserId == userId) throw Exception('Cannot follow yourself');

    try {
      final followId = '${currentUserId}_$userId';

      // Check if already following
      final existingFollow = await _follows.doc(followId).get();
      if (existingFollow.exists) {
        throw Exception('Already following this user');
      }

      await _firestore.runTransaction((transaction) async {
        // Create follow relationship with additional metadata
        transaction.set(_follows.doc(followId), {
          'id': followId,
          'followerId': currentUserId,
          'followedId': userId,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update follower count for the followed user
        transaction.update(_users.doc(userId), {
          'followersCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update following count for the current user
        transaction.update(_users.doc(currentUserId), {
          'followingCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (kDebugMode) debugPrint('✅ Successfully followed user: $userId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error following user: $e');
      rethrow;
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String userId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final followId = '${currentUserId}_$userId';

      // Check if currently following
      final existingFollow = await _follows.doc(followId).get();
      if (!existingFollow.exists) {
        throw Exception('Not currently following this user');
      }

      await _firestore.runTransaction((transaction) async {
        // Remove follow relationship
        transaction.delete(_follows.doc(followId));

        // Update follower count for the unfollowed user
        transaction.update(_users.doc(userId), {
          'followersCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update following count for the current user
        transaction.update(_users.doc(currentUserId), {
          'followingCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (kDebugMode) debugPrint('✅ Successfully unfollowed user: $userId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error unfollowing user: $e');
      rethrow;
    }
  }

  /// Check if following a user
  Future<bool> isFollowing(String userId) async {
    if (currentUserId == null) return false;

    try {
      final followId = '${currentUserId}_$userId';
      final doc = await _follows.doc(followId).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking follow status: $e');
      return false;
    }
  }

  /// Get list of users that the current user is following
  Future<List<Map<String, dynamic>>> getFollowing({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) return [];

      final snapshot = await _follows
          .where('followerId', isEqualTo: targetUserId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      final followingUserIds = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['followedId'] as String)
          .toList();

      // Get user details for each following
      final followingUsers = <Map<String, dynamic>>[];
      for (final followedUserId in followingUserIds) {
        final userDoc = await _users.doc(followedUserId).get();
        if (userDoc.exists) {
          followingUsers.add({
            ...userDoc.data() as Map<String, dynamic>,
            'id': userDoc.id
          });
        }
      }

      return followingUsers;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting following list: $e');
      return [];
    }
  }

  /// Get list of users that follow the specified user
  Future<List<Map<String, dynamic>>> getFollowers({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) return [];

      final snapshot = await _follows
          .where('followedId', isEqualTo: targetUserId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      final followerUserIds = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['followerId'] as String)
          .toList();

      // Get user details for each follower
      final followers = <Map<String, dynamic>>[];
      for (final followerUserId in followerUserIds) {
        final userDoc = await _users.doc(followerUserId).get();
        if (userDoc.exists) {
          followers.add({
            ...userDoc.data() as Map<String, dynamic>,
            'id': userDoc.id
          });
        }
      }

      return followers;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting followers list: $e');
      return [];
    }
  }

  /// Get follow statistics for a user
  Future<Map<String, int>> getFollowStats({String? userId}) async {
    try {
      final targetUserId = userId ?? currentUserId;
      if (targetUserId == null) {
        return {'followersCount': 0, 'followingCount': 0};
      }

      final userDoc = await _users.doc(targetUserId).get();
      if (!userDoc.exists) {
        return {'followersCount': 0, 'followingCount': 0};
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      return {
        'followersCount': userData['followersCount'] ?? 0,
        'followingCount': userData['followingCount'] ?? 0,
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting follow stats: $e');
      return {'followersCount': 0, 'followingCount': 0};
    }
  }

  /// Check if two users are mutual follows
  Future<bool> areMutualFollows(String userId) async {
    if (currentUserId == null) return false;

    try {
      final followId1 = '${currentUserId}_$userId';
      final followId2 = '${userId}_$currentUserId';

      final follow1 = await _follows.doc(followId1).get();
      final follow2 = await _follows.doc(followId2).get();

      return follow1.exists && follow2.exists;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking mutual follows: $e');
      return false;
    }
  }

  // ==================== MESSAGING SYSTEM ====================

  /// Send a message to another user
  Future<void> sendMessage(String recipientId, String content, {bool isPending = false}) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      final messageData = {
        'senderId': currentUserId,
        'recipientId': recipientId,
        'content': content,
        'isPending': isPending,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _messages.add(messageData);
      await docRef.update({'id': docRef.id});

      if (kDebugMode) debugPrint('✅ Message sent to $recipientId (pending: $isPending)');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error sending message: $e');
      throw Exception('Failed to send message');
    }
  }

  /// Get pending message count between current user and another user
  Future<int> getPendingMessageCount(String userId) async {
    if (currentUserId == null) return 0;

    try {
      final snapshot = await _messages
          .where('senderId', isEqualTo: currentUserId)
          .where('recipientId', isEqualTo: userId)
          .where('isPending', isEqualTo: true)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting pending message count: $e');
      return 0;
    }
  }

  /// Get messages between two users
  Future<List<Map<String, dynamic>>> getMessages(String userId) async {
    if (currentUserId == null) return [];

    try {
      final snapshot1 = await _messages
          .where('senderId', isEqualTo: currentUserId)
          .where('recipientId', isEqualTo: userId)
          .get();

      final snapshot2 = await _messages
          .where('senderId', isEqualTo: userId)
          .where('recipientId', isEqualTo: currentUserId)
          .get();

      final allMessages = [
        ...snapshot1.docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}),
        ...snapshot2.docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}),
      ];

      // Sort by timestamp
      allMessages.sort((a, b) {
        final aTime = a['createdAt'] as Timestamp?;
        final bTime = b['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });

      return allMessages;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting messages: $e');
      return [];
    }
  }

  /// Convert pending messages to active when users become mutual follows
  Future<void> activatePendingMessages(String userId) async {
    if (currentUserId == null) return;

    try {
      // Get all pending messages between the two users
      final snapshot1 = await _messages
          .where('senderId', isEqualTo: currentUserId)
          .where('recipientId', isEqualTo: userId)
          .where('isPending', isEqualTo: true)
          .get();

      final snapshot2 = await _messages
          .where('senderId', isEqualTo: userId)
          .where('recipientId', isEqualTo: currentUserId)
          .where('isPending', isEqualTo: true)
          .get();

      final batch = _firestore.batch();

      // Update all pending messages to active
      for (final doc in [...snapshot1.docs, ...snapshot2.docs]) {
        batch.update(doc.reference, {
          'isPending': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (kDebugMode) debugPrint('✅ Activated pending messages with user: $userId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error activating pending messages: $e');
    }
  }

  // ==================== NOTIFICATION SYSTEM ====================

  /// Create a notification
  Future<void> createNotification({
    required String recipientId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    if (currentUserId == null) return;

    try {
      final notificationData = {
        'recipientId': recipientId,
        'senderId': currentUserId,
        'type': type,
        'title': title,
        'message': message,
        'data': data ?? {},
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _notifications.add(notificationData);
      await docRef.update({'id': docRef.id});

      if (kDebugMode) debugPrint('✅ Notification created for user: $recipientId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error creating notification: $e');
    }
  }

  /// Get notifications for current user
  Future<List<Map<String, dynamic>>> getNotifications() async {
    if (currentUserId == null) return [];

    try {
      final snapshot = await _notifications
          .where('recipientId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notifications.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    if (currentUserId == null) return;

    try {
      final snapshot = await _notifications
          .where('recipientId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      if (kDebugMode) debugPrint('✅ All notifications marked as read');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Initialize app configuration data
  Future<void> initializeAppConfig() async {
    try {
      // Food preferences
      await _appConfig.doc('food_preferences').set({
        'id': 'food_preferences',
        'data': [
          'Italian', 'Mexican', 'Chinese', 'Japanese', 'Korean', 'Thai', 'Vietnamese',
          'Indian', 'Mediterranean', 'French', 'American', 'BBQ', 'Seafood', 'Steakhouse',
          'Vegetarian', 'Vegan', 'Gluten-Free', 'Organic', 'Raw Foods', 'Keto',
          'Fast Food', 'Street Food', 'Food Trucks', 'Fine Dining', 'Casual Dining',
          'Pizza', 'Burgers', 'Sushi', 'Ramen', 'Pasta', 'Desserts', 'Ice Cream',
          'Coffee', 'Wine Bar', 'Craft Beer', 'Cocktails', 'Smoothies',
        ],
        'version': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Dietary restrictions
      await _appConfig.doc('dietary_restrictions').set({
        'id': 'dietary_restrictions',
        'data': [
          'None', 'Vegetarian', 'Vegan', 'Gluten-Free', 'Dairy-Free', 'Nut-Free',
          'Shellfish-Free', 'Kosher', 'Halal', 'Keto', 'Paleo', 'Low-Carb',
        ],
        'version': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing app config: $e');
    }
  }

  /// Get app configuration
  Future<List<String>> getAppConfig(String configId) async {
    try {
      final doc = await _appConfig.doc(configId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting app config: $e');
      return [];
    }
  }

  // ==================== POSTS MANAGEMENT ====================

  /// Clear social feed data (posts, likes, follows, notifications)
  /// Keeps restaurants and users intact
  Future<void> clearSocialFeedData() async {
    try {
      if (kDebugMode) debugPrint('🧹 Starting to clear social feed data...');

      // Clear posts collection
      await _clearCollection('posts', 'posts');

      // Clear likes collection
      await _clearCollection('likes', 'likes');

      // Clear follows collection
      await _clearCollection('follows', 'follows');

      // Clear notifications collection
      await _clearCollection('notifications', 'notifications');

      // Clear messages collection
      await _clearCollection('messages', 'messages');

      // Reset user social counts
      await _resetUserSocialCounts();

      if (kDebugMode) debugPrint('✅ Social feed data cleared successfully');

    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error clearing social feed data: $e');
      throw Exception('Failed to clear social feed data');
    }
  }

  /// Helper method to clear a collection
  Future<void> _clearCollection(String collectionName, String displayName) async {
    try {
      if (kDebugMode) debugPrint('🗑️ Clearing $displayName collection...');

      final snapshot = await _firestore.collection(collectionName).limit(500).get();

      if (snapshot.docs.isEmpty) {
        if (kDebugMode) debugPrint('📭 $displayName collection is already empty');
        return;
      }

      // Delete in batches to avoid hitting Firestore limits
      final batch = _firestore.batch();
      int count = 0;

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
        count++;

        // Commit batch every 500 operations (Firestore limit)
        if (count >= 500) {
          await batch.commit();
          if (kDebugMode) debugPrint('🔄 Committed batch of $count $displayName deletions');
          return _clearCollection(collectionName, displayName); // Recursive call for remaining
        }
      }

      // Commit remaining operations
      if (count > 0) {
        await batch.commit();
        if (kDebugMode) debugPrint('✅ Deleted $count documents from $displayName');
      }

    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error clearing $collectionName: $e');
      rethrow;
    }
  }

  /// Reset social counts in user profiles
  Future<void> _resetUserSocialCounts() async {
    try {
      if (kDebugMode) debugPrint('🔄 Resetting user social counts...');

      final usersSnapshot = await _users.get();
      final batch = _firestore.batch();

      for (final userDoc in usersSnapshot.docs) {
        batch.update(userDoc.reference, {
          'followersCount': 0,
          'followingCount': 0,
          'postsCount': 0,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      if (kDebugMode) debugPrint('✅ Reset social counts for ${usersSnapshot.docs.length} users');

    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error resetting user social counts: $e');
      rethrow;
    }
  }

  /// Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    try {
      final batch = _firestore.batch();

      // Note: In production, you should use Firestore's bulk delete
      // This is simplified for development
      if (kDebugMode) {
        debugPrint('Clear all data method called - implement with caution');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error clearing data: $e');
    }
  }
}