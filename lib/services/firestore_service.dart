import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== USER MANAGEMENT ==========

  /// Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String? username,
    String? bio,
    String? location,
    List<String> foodPreferences = const [],
    List<String> interests = const [],
    int? age,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'username': username ?? email.split('@')[0],
        'bio': bio ?? 'Food enthusiast exploring new culinary experiences!',
        'location': location ?? '',
        'profilePicture': null,
        'isVerified': false,
        'isEmailVerified': true,
        'postsCount': 0,
        'followersCount': 0,
        'followingCount': 0,
        'rating': 5.0,
        'age': age,
        'foodPreferences': foodPreferences,
        'interests': interests,
        'joinedDate': FieldValue.serverTimestamp(),
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile by UID
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Search users by name or username
  Stream<List<Map<String, dynamic>>> searchUsers(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  // ========== RESTAURANTS ==========

  /// Get all restaurants
  Stream<List<Map<String, dynamic>>> getRestaurants() {
    return _firestore
        .collection('restaurants')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  /// Get restaurant by ID
  Future<Map<String, dynamic>?> getRestaurant(String restaurantId) async {
    try {
      final doc = await _firestore.collection('restaurants').doc(restaurantId).get();
      return doc.exists ? {...doc.data()!, 'id': doc.id} : null;
    } catch (e) {
      print('Error getting restaurant: $e');
      return null;
    }
  }

  /// Get restaurants by cuisine
  Stream<List<Map<String, dynamic>>> getRestaurantsByCuisine(String cuisine) {
    return _firestore
        .collection('restaurants')
        .where('cuisine', isEqualTo: cuisine)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  /// Get restaurants within radius (requires geo-point queries)
  Stream<List<Map<String, dynamic>>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) {
    // Basic implementation - in production, use GeoFlutterFire for proper geo queries
    return _firestore
        .collection('restaurants')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .where((restaurant) {
              final lat = restaurant['latitude'] as double?;
              final lng = restaurant['longitude'] as double?;
              if (lat == null || lng == null) return false;

              // Simple distance calculation (not accurate for large distances)
              final distance = _calculateDistance(latitude, longitude, lat, lng);
              return distance <= radiusKm;
            })
            .toList());
  }

  // ========== MEAL SESSIONS ==========

  /// Create a new meal session
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
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final docRef = await _firestore.collection('meal_sessions').add({
        'hostUserId': currentUser.uid,
        'title': title,
        'description': description,
        'restaurantId': restaurantId,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'maxParticipants': maxParticipants,
        'currentParticipants': 1, // Host counts as participant
        'status': 'open', // open, full, completed, cancelled
        'preferences': preferences ?? {},
        'joinedUsers': [currentUser.uid], // Host is automatically joined
        'pendingUsers': invitedUsers,
        'rejectedUsers': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating meal session: $e');
      rethrow;
    }
  }

  /// Get meal sessions (discover screen)
  Stream<List<Map<String, dynamic>>> getOpenMealSessions() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('meal_sessions')
        .where('status', isEqualTo: 'open')
        .where('hostUserId', isNotEqualTo: currentUser.uid) // Exclude own sessions
        .orderBy('hostUserId') // Required for inequality
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .where((session) {
              // Additional filter to exclude sessions user already joined/pending
              final joinedUsers = List<String>.from(session['joinedUsers'] ?? []);
              final pendingUsers = List<String>.from(session['pendingUsers'] ?? []);
              return !joinedUsers.contains(currentUser.uid) &&
                     !pendingUsers.contains(currentUser.uid);
            })
            .toList());
  }

  /// Get user's own meal sessions
  Stream<List<Map<String, dynamic>>> getUserMealSessions() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('meal_sessions')
        .where('hostUserId', isEqualTo: currentUser.uid)
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  /// Get sessions user joined (matches screen - active sessions)
  Stream<List<Map<String, dynamic>>> getJoinedMealSessions() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('meal_sessions')
        .where('joinedUsers', arrayContains: currentUser.uid)
        .where('hostUserId', isNotEqualTo: currentUser.uid) // Exclude own sessions
        .orderBy('hostUserId') // Required for inequality
        .orderBy('scheduledTime', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  /// Get pending join requests for user's sessions (matches screen - pending requests)
  Stream<List<Map<String, dynamic>>> getPendingJoinRequests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('meal_sessions')
        .where('hostUserId', isEqualTo: currentUser.uid)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Map<String, dynamic>> requests = [];

          for (final doc in snapshot.docs) {
            final sessionData = {...doc.data(), 'id': doc.id};
            final pendingUserIds = List<String>.from(sessionData['pendingUsers'] ?? []);

            for (final userId in pendingUserIds) {
              final userData = await getUserProfile(userId);
              if (userData != null) {
                requests.add({
                  'id': 'request_${doc.id}_$userId',
                  'sessionId': doc.id,
                  'session': sessionData,
                  'user': userData,
                  'userId': userId,
                  'requestedAt': sessionData['createdAt'],
                  'status': 'pending',
                });
              }
            }
          }

          return requests;
        });
  }

  /// Join a meal session
  Future<void> joinMealSession(String sessionId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await _firestore.runTransaction((transaction) async {
        final sessionRef = _firestore.collection('meal_sessions').doc(sessionId);
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) throw Exception('Session not found');

        final sessionData = sessionDoc.data()!;
        final currentParticipants = sessionData['currentParticipants'] as int;
        final maxParticipants = sessionData['maxParticipants'] as int;

        if (currentParticipants >= maxParticipants) {
          throw Exception('Session is full');
        }

        final pendingUsers = List<String>.from(sessionData['pendingUsers'] ?? []);
        if (!pendingUsers.contains(currentUser.uid)) {
          pendingUsers.add(currentUser.uid);
        }

        transaction.update(sessionRef, {
          'pendingUsers': pendingUsers,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error joining meal session: $e');
      rethrow;
    }
  }

  /// Accept join request
  Future<void> acceptJoinRequest(String sessionId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final sessionRef = _firestore.collection('meal_sessions').doc(sessionId);
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) throw Exception('Session not found');

        final sessionData = sessionDoc.data()!;
        final pendingUsers = List<String>.from(sessionData['pendingUsers'] ?? []);
        final joinedUsers = List<String>.from(sessionData['joinedUsers'] ?? []);

        if (pendingUsers.contains(userId) && !joinedUsers.contains(userId)) {
          pendingUsers.remove(userId);
          joinedUsers.add(userId);

          transaction.update(sessionRef, {
            'pendingUsers': pendingUsers,
            'joinedUsers': joinedUsers,
            'currentParticipants': joinedUsers.length,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error accepting join request: $e');
      rethrow;
    }
  }

  /// Reject join request
  Future<void> rejectJoinRequest(String sessionId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final sessionRef = _firestore.collection('meal_sessions').doc(sessionId);
        final sessionDoc = await transaction.get(sessionRef);

        if (!sessionDoc.exists) throw Exception('Session not found');

        final sessionData = sessionDoc.data()!;
        final pendingUsers = List<String>.from(sessionData['pendingUsers'] ?? []);
        final rejectedUsers = List<String>.from(sessionData['rejectedUsers'] ?? []);

        if (pendingUsers.contains(userId)) {
          pendingUsers.remove(userId);
          rejectedUsers.add(userId);

          transaction.update(sessionRef, {
            'pendingUsers': pendingUsers,
            'rejectedUsers': rejectedUsers,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error rejecting join request: $e');
      rethrow;
    }
  }

  // ========== SOCIAL FEATURES ==========

  /// Create a new post
  Future<String> createPost({
    required String caption,
    String? imageUrl,
    String? location,
    String? restaurantId,
    List<String> hashtags = const [],
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      final docRef = await _firestore.collection('posts').add({
        'userId': currentUser.uid,
        'imageUrl': imageUrl,
        'caption': caption,
        'location': location,
        'restaurantId': restaurantId,
        'hashtags': hashtags,
        'likesCount': 0,
        'commentsCount': 0,
        'sharesCount': 0,
        'likedBy': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  /// Get posts feed
  Stream<List<Map<String, dynamic>>> getPostsFeed() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  /// Get user's posts
  Stream<List<Map<String, dynamic>>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  /// Like/unlike a post
  Future<void> togglePostLike(String postId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await _firestore.runTransaction((transaction) async {
        final postRef = _firestore.collection('posts').doc(postId);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) throw Exception('Post not found');

        final postData = postDoc.data()!;
        final likedBy = List<String>.from(postData['likedBy'] ?? []);
        final likesCount = postData['likesCount'] as int;

        if (likedBy.contains(currentUser.uid)) {
          // Unlike
          likedBy.remove(currentUser.uid);
          transaction.update(postRef, {
            'likedBy': likedBy,
            'likesCount': likesCount - 1,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Like
          likedBy.add(currentUser.uid);
          transaction.update(postRef, {
            'likedBy': likedBy,
            'likesCount': likesCount + 1,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      print('Error toggling post like: $e');
      rethrow;
    }
  }

  // ========== MESSAGING ==========

  /// Create or get conversation
  Future<String> createOrGetConversation(List<String> participants) async {
    try {
      participants.sort(); // Ensure consistent ordering
      final conversationId = participants.join('_');

      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      final conversationDoc = await conversationRef.get();

      if (!conversationDoc.exists) {
        await conversationRef.set({
          'participants': participants,
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': {},
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return conversationId;
    } catch (e) {
      print('Error creating conversation: $e');
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
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await _firestore.collection('conversations').doc(conversationId)
          .collection('messages').add({
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'text': text,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update conversation last message
      await _firestore.collection('conversations').doc(conversationId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  /// Get messages for conversation
  Stream<List<Map<String, dynamic>>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  /// Get user's conversations
  Stream<List<Map<String, dynamic>>> getUserConversations() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data(), 'id': doc.id})
            .toList());
  }

  // ========== FOLLOWERS/FOLLOWING ==========

  /// Follow a user
  Future<void> followUser(String userIdToFollow) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await _firestore.runTransaction((transaction) async {
        final followerRef = _firestore.collection('followers').doc(userIdToFollow);
        final followingRef = _firestore.collection('following').doc(currentUser.uid);

        final followerDoc = await transaction.get(followerRef);
        final followingDoc = await transaction.get(followingRef);

        // Update followers collection
        List<String> followers = [];
        if (followerDoc.exists) {
          followers = List<String>.from(followerDoc.data()?['users'] ?? []);
        }
        if (!followers.contains(currentUser.uid)) {
          followers.add(currentUser.uid);
        }
        transaction.set(followerRef, {'users': followers}, SetOptions(merge: true));

        // Update following collection
        List<String> following = [];
        if (followingDoc.exists) {
          following = List<String>.from(followingDoc.data()?['users'] ?? []);
        }
        if (!following.contains(userIdToFollow)) {
          following.add(userIdToFollow);
        }
        transaction.set(followingRef, {'users': following}, SetOptions(merge: true));

        // Update user counts
        final targetUserRef = _firestore.collection('users').doc(userIdToFollow);
        final currentUserRef = _firestore.collection('users').doc(currentUser.uid);

        transaction.update(targetUserRef, {
          'followersCount': FieldValue.increment(1),
        });
        transaction.update(currentUserRef, {
          'followingCount': FieldValue.increment(1),
        });
      });
    } catch (e) {
      print('Error following user: $e');
      rethrow;
    }
  }

  /// Unfollow a user
  Future<void> unfollowUser(String userIdToUnfollow) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await _firestore.runTransaction((transaction) async {
        final followerRef = _firestore.collection('followers').doc(userIdToUnfollow);
        final followingRef = _firestore.collection('following').doc(currentUser.uid);

        final followerDoc = await transaction.get(followerRef);
        final followingDoc = await transaction.get(followingRef);

        // Update followers collection
        if (followerDoc.exists) {
          List<String> followers = List<String>.from(followerDoc.data()?['users'] ?? []);
          followers.remove(currentUser.uid);
          transaction.update(followerRef, {'users': followers});
        }

        // Update following collection
        if (followingDoc.exists) {
          List<String> following = List<String>.from(followingDoc.data()?['users'] ?? []);
          following.remove(userIdToUnfollow);
          transaction.update(followingRef, {'users': following});
        }

        // Update user counts
        final targetUserRef = _firestore.collection('users').doc(userIdToUnfollow);
        final currentUserRef = _firestore.collection('users').doc(currentUser.uid);

        transaction.update(targetUserRef, {
          'followersCount': FieldValue.increment(-1),
        });
        transaction.update(currentUserRef, {
          'followingCount': FieldValue.increment(-1),
        });
      });
    } catch (e) {
      print('Error unfollowing user: $e');
      rethrow;
    }
  }

  // ========== UTILITY METHODS ==========

  /// Calculate distance between two points (simple formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    const double c = 0.00000000000000001; // Almost zero, to avoid division by zero
    double a = 0.5 -
        (lat2 - lat1) * p / 2 +
        (1 - (lat2 - lat1) * p / 2) *
        (1 - (lon2 - lon1) * p / 2) *
        2 *
        (sin(lat1 * p) * sin(lat2 * p) +
         cos(lat1 * p) * cos(lat2 * p) * cos((lon2 - lon1) * p));
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  /// Update user online status
  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore.collection('users').doc(currentUser.uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating online status: $e');
    }
  }
}