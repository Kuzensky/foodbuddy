// FoodBuddy App - Comprehensive Dummy Data
// Based on plan.md specifications for all app features

class DummyData {
  // ========== USER PROFILES ==========
  static final List<Map<String, dynamic>> users = [
    {
      'id': 'user_001',
      'name': 'Sarah Chen',
      'username': 'sarahc',
      'email': 'sarah.chen@email.com',
      'profilePicture': null, // Will use initials
      'bio': 'Food enthusiast who loves exploring new cuisines and meeting fellow food lovers! Always up for trying new restaurants.',
      'isVerified': true,
      'isEmailVerified': true,
      'postsCount': 24,
      'followersCount': 342,
      'followingCount': 186,
      'rating': 4.8,
      'location': 'Downtown',
      'age': 28,
      'foodPreferences': ['Italian', 'Vegetarian', 'Asian Cuisine', 'Gluten-Free'],
      'interests': ['Fine Dining', 'Cooking', 'Food Photography'],
      'joinedDate': '2023-01-15T10:30:00Z',
      'isOnline': true,
      'lastSeen': '2024-01-20T15:45:00Z',
    },
    {
      'id': 'user_002',
      'name': 'Mike Johnson',
      'username': 'mikej',
      'email': 'mike.johnson@email.com',
      'profilePicture': null,
      'bio': 'Home chef and restaurant reviewer. Love sharing my culinary adventures and discovering hidden gems!',
      'isVerified': false,
      'isEmailVerified': true,
      'postsCount': 18,
      'followersCount': 256,
      'followingCount': 94,
      'rating': 4.6,
      'location': 'Midtown',
      'age': 32,
      'foodPreferences': ['BBQ', 'Mexican Food', 'Craft Beer', 'Seafood'],
      'interests': ['Home Cooking', 'Food Reviews', 'Beer Tasting'],
      'joinedDate': '2023-03-22T14:20:00Z',
      'isOnline': false,
      'lastSeen': '2024-01-20T12:30:00Z',
    },
    {
      'id': 'user_003',
      'name': 'Emma Rodriguez',
      'username': 'emmar',
      'email': 'emma.rodriguez@email.com',
      'profilePicture': null,
      'bio': 'Foodie and travel blogger exploring the world one bite at a time. Vegan lifestyle advocate.',
      'isVerified': true,
      'isEmailVerified': true,
      'postsCount': 45,
      'followersCount': 512,
      'followingCount': 203,
      'rating': 4.9,
      'location': 'Brooklyn',
      'age': 26,
      'foodPreferences': ['Vegan', 'Organic', 'Raw Foods', 'Mediterranean'],
      'interests': ['Travel', 'Food Blogging', 'Sustainable Eating'],
      'joinedDate': '2022-11-08T09:15:00Z',
      'isOnline': true,
      'lastSeen': '2024-01-20T16:22:00Z',
    },
    {
      'id': 'user_004',
      'name': 'David Kim',
      'username': 'davidk',
      'email': 'david.kim@email.com',
      'profilePicture': null,
      'bio': 'Korean food specialist and culinary student. Always excited to share authentic recipes!',
      'isVerified': false,
      'isEmailVerified': true,
      'postsCount': 31,
      'followersCount': 189,
      'followingCount': 142,
      'rating': 4.7,
      'location': 'Queens',
      'age': 24,
      'foodPreferences': ['Korean', 'Asian Fusion', 'Spicy Food', 'Street Food'],
      'interests': ['Culinary Arts', 'Recipe Development', 'Food Culture'],
      'joinedDate': '2023-05-10T11:40:00Z',
      'isOnline': true,
      'lastSeen': '2024-01-20T16:45:00Z',
    },
    {
      'id': 'user_005',
      'name': 'Lisa Thompson',
      'username': 'lisath',
      'email': 'lisa.thompson@email.com',
      'profilePicture': null,
      'bio': 'Pastry chef and dessert lover. Creating sweet memories one dessert at a time!',
      'isVerified': true,
      'isEmailVerified': true,
      'postsCount': 52,
      'followersCount': 678,
      'followingCount': 234,
      'rating': 4.9,
      'location': 'Manhattan',
      'age': 29,
      'foodPreferences': ['Desserts', 'French Pastry', 'Chocolate', 'Coffee'],
      'interests': ['Baking', 'Pastry Arts', 'Coffee Culture'],
      'joinedDate': '2022-08-14T13:25:00Z',
      'isOnline': false,
      'lastSeen': '2024-01-20T14:10:00Z',
    },
  ];

  // ========== FOLLOWERS/FOLLOWING RELATIONSHIPS ==========
  static final Map<String, List<String>> followRelationships = {
    'user_001': ['user_002', 'user_003', 'user_005'], // Sarah follows Mike, Emma, Lisa
    'user_002': ['user_001', 'user_004'], // Mike follows Sarah, David
    'user_003': ['user_001', 'user_004', 'user_005'], // Emma follows Sarah, David, Lisa
    'user_004': ['user_001', 'user_002', 'user_003'], // David follows Sarah, Mike, Emma
    'user_005': ['user_001', 'user_003', 'user_004'], // Lisa follows Sarah, Emma, David
  };

  // ========== POSTS (Social Feed) ==========
  static final List<Map<String, dynamic>> posts = [
    {
      'id': 'post_001',
      'userId': 'user_001',
      'imageUrl': 'assets/images/pasta_dish.jpg',
      'caption': 'Amazing truffle pasta at Giovanni\'s! The flavor combination was absolutely perfect. Highly recommend trying this if you\'re in the area! 🍝✨',
      'location': 'Giovanni\'s Italian Restaurant, Downtown',
      'timestamp': '2024-01-20T14:30:00Z',
      'likesCount': 42,
      'commentsCount': 8,
      'sharesCount': 3,
      'hashtags': ['#ItalianFood', '#TrufflePasta', '#Foodie', '#Downtown'],
      'restaurantId': 'rest_001',
      'isLikedByCurrentUser': false,
    },
    {
      'id': 'post_002',
      'userId': 'user_002',
      'imageUrl': 'assets/images/bbq_ribs.jpg',
      'caption': 'Perfect BBQ ribs with homemade dry rub. Spent 6 hours smoking these beauties. The wait was absolutely worth it! 🔥',
      'location': 'Home Kitchen, Midtown',
      'timestamp': '2024-01-20T12:15:00Z',
      'likesCount': 67,
      'commentsCount': 12,
      'sharesCount': 5,
      'hashtags': ['#BBQ', '#Homemade', '#SmokingMeat', '#Ribs'],
      'restaurantId': null,
      'isLikedByCurrentUser': true,
    },
    {
      'id': 'post_003',
      'userId': 'user_003',
      'imageUrl': 'assets/images/vegan_bowl.jpg',
      'caption': 'Colorful Buddha bowl packed with nutrients! Quinoa, roasted veggies, and tahini dressing. Plant-based eating at its finest! 🌱',
      'location': 'Green Leaf Café, Brooklyn',
      'timestamp': '2024-01-20T10:45:00Z',
      'likesCount': 89,
      'commentsCount': 15,
      'sharesCount': 7,
      'hashtags': ['#VeganFood', '#BuddhaBowl', '#PlantBased', '#Healthy'],
      'restaurantId': 'rest_002',
      'isLikedByCurrentUser': true,
    },
    {
      'id': 'post_004',
      'userId': 'user_004',
      'imageUrl': 'assets/images/korean_bbq.jpg',
      'caption': 'Traditional Korean BBQ night with friends! Nothing beats good food and great company. The kimchi was especially amazing tonight! 🥢',
      'location': 'Seoul Kitchen, Queens',
      'timestamp': '2024-01-19T19:30:00Z',
      'likesCount': 56,
      'commentsCount': 9,
      'sharesCount': 2,
      'hashtags': ['#KoreanBBQ', '#FriendsTime', '#Kimchi', '#Traditional'],
      'restaurantId': 'rest_003',
      'isLikedByCurrentUser': false,
    },
    {
      'id': 'post_005',
      'userId': 'user_005',
      'imageUrl': 'assets/images/chocolate_cake.jpg',
      'caption': 'Triple chocolate layer cake I made for a special celebration! Dark chocolate, milk chocolate, and white chocolate mousse. Pure indulgence! 🍰',
      'location': 'Home Bakery, Manhattan',
      'timestamp': '2024-01-19T16:20:00Z',
      'likesCount': 134,
      'commentsCount': 23,
      'sharesCount': 11,
      'hashtags': ['#ChocolateCake', '#Homemade', '#Dessert', '#Celebration'],
      'restaurantId': null,
      'isLikedByCurrentUser': true,
    },
  ];

  // ========== COMMENTS ==========
  static final List<Map<String, dynamic>> comments = [
    {
      'id': 'comment_001',
      'postId': 'post_001',
      'userId': 'user_002',
      'text': 'This looks incredible! I need to try Giovanni\'s soon.',
      'timestamp': '2024-01-20T14:45:00Z',
      'likesCount': 3,
    },
    {
      'id': 'comment_002',
      'postId': 'post_001',
      'userId': 'user_003',
      'text': 'Truffle pasta is my weakness! 😍',
      'timestamp': '2024-01-20T15:10:00Z',
      'likesCount': 1,
    },
    {
      'id': 'comment_003',
      'postId': 'post_002',
      'userId': 'user_001',
      'text': 'Your BBQ skills are amazing! Recipe please? 🙏',
      'timestamp': '2024-01-20T12:30:00Z',
      'likesCount': 5,
    },
    {
      'id': 'comment_004',
      'postId': 'post_003',
      'userId': 'user_004',
      'text': 'This bowl looks so fresh and colorful! What\'s in the dressing?',
      'timestamp': '2024-01-20T11:15:00Z',
      'likesCount': 2,
    },
  ];

  // ========== MEAL SESSIONS (Discover & Matches) ==========
  static final List<Map<String, dynamic>> mealSessions = [
    {
      'id': 'session_001',
      'hostUserId': 'user_001',
      'title': 'Italian Food Tasting Night',
      'description': 'Looking for fellow Italian food lovers to explore authentic dishes at Giovanni\'s! Let\'s share some amazing pasta and wine.',
      'restaurantId': 'rest_001',
      'scheduledTime': '2024-01-22T19:00:00Z',
      'maxParticipants': 4,
      'currentParticipants': 2,
      'status': 'open', // open, full, completed, cancelled
      'preferences': {
        'ageRange': [25, 35],
        'foodTypes': ['Italian', 'Wine'],
        'dietaryRestrictions': ['No Nuts'],
        'priceRange': [30, 60],
      },
      'joinedUsers': ['user_003', 'user_005'],
      'pendingUsers': ['user_002'],
      'createdAt': '2024-01-20T10:00:00Z',
    },
    {
      'id': 'session_002',
      'hostUserId': 'user_004',
      'title': 'Korean BBQ Experience',
      'description': 'Join me for an authentic Korean BBQ experience! Perfect for anyone wanting to try traditional Korean cuisine.',
      'restaurantId': 'rest_003',
      'scheduledTime': '2024-01-23T18:30:00Z',
      'maxParticipants': 6,
      'currentParticipants': 3,
      'status': 'open',
      'preferences': {
        'ageRange': [22, 40],
        'foodTypes': ['Korean', 'Spicy', 'Meat'],
        'dietaryRestrictions': [],
        'priceRange': [25, 50],
      },
      'joinedUsers': ['user_001', 'user_002', 'user_005'],
      'pendingUsers': [],
      'createdAt': '2024-01-19T14:30:00Z',
    },
    {
      'id': 'session_003',
      'hostUserId': 'user_003',
      'title': 'Vegan Brunch Meetup',
      'description': 'Calling all plant-based food lovers! Let\'s enjoy a delicious vegan brunch together and share our favorite recipes.',
      'restaurantId': 'rest_002',
      'scheduledTime': '2024-01-24T11:00:00Z',
      'maxParticipants': 5,
      'currentParticipants': 1,
      'status': 'open',
      'preferences': {
        'ageRange': [20, 45],
        'foodTypes': ['Vegan', 'Organic', 'Healthy'],
        'dietaryRestrictions': ['Vegan Only'],
        'priceRange': [15, 35],
      },
      'joinedUsers': ['user_005'],
      'pendingUsers': ['user_001'],
      'createdAt': '2024-01-18T16:45:00Z',
    },
  ];

  // ========== RESTAURANTS (Map & Filter Data) ==========
  static final List<Map<String, dynamic>> restaurants = [
    {
      'id': 'rest_001',
      'name': 'Giovanni\'s Italian Restaurant',
      'cuisine': 'Italian',
      'address': '123 Main St, Downtown',
      'latitude': 40.7589,
      'longitude': -73.9851,
      'phone': '+1-555-0123',
      'website': 'www.giovannis.com',
      'rating': 4.5,
      'reviewCount': 247,
      'priceRange': 'PP', // $, $$, $$$, $$$$
      'description': 'Authentic Italian cuisine with traditional recipes passed down through generations.',
      'imageUrl': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
      'hours': {
        'monday': '11:00-22:00',
        'tuesday': '11:00-22:00',
        'wednesday': '11:00-22:00',
        'thursday': '11:00-22:00',
        'friday': '11:00-23:00',
        'saturday': '11:00-23:00',
        'sunday': '12:00-21:00',
      },
      'features': ['Outdoor Seating', 'Wine Bar', 'Reservations'],
      'images': ['assets/images/giovanni_interior.jpg', 'assets/images/giovanni_pasta.jpg'],
    },
    {
      'id': 'rest_002',
      'name': 'Green Leaf Café',
      'cuisine': 'Vegan',
      'address': '456 Brooklyn Ave, Brooklyn',
      'latitude': 40.6782,
      'longitude': -73.9442,
      'phone': '+1-555-0456',
      'website': 'www.greenleafcafe.com',
      'rating': 4.7,
      'reviewCount': 189,
      'priceRange': 'P',
      'description': 'Fresh, organic, plant-based meals that nourish both body and soul.',
      'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      'hours': {
        'monday': '07:00-20:00',
        'tuesday': '07:00-20:00',
        'wednesday': '07:00-20:00',
        'thursday': '07:00-20:00',
        'friday': '07:00-21:00',
        'saturday': '08:00-21:00',
        'sunday': '08:00-19:00',
      },
      'features': ['Vegan Only', 'Organic', 'Smoothies', 'WiFi'],
      'images': ['assets/images/greenleaf_interior.jpg', 'assets/images/greenleaf_bowl.jpg'],
    },
    {
      'id': 'rest_003',
      'name': 'Seoul Kitchen',
      'cuisine': 'Korean',
      'address': '789 Queens Blvd, Queens',
      'latitude': 40.7282,
      'longitude': -73.7949,
      'phone': '+1-555-0789',
      'website': 'www.seoulkitchen.com',
      'rating': 4.4,
      'reviewCount': 312,
      'priceRange': 'PP',
      'description': 'Traditional Korean BBQ and authentic dishes in a modern setting.',
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
      'hours': {
        'monday': 'Closed',
        'tuesday': '17:00-23:00',
        'wednesday': '17:00-23:00',
        'thursday': '17:00-23:00',
        'friday': '17:00-24:00',
        'saturday': '16:00-24:00',
        'sunday': '16:00-22:00',
      },
      'features': ['Korean BBQ', 'Private Rooms', 'Karaoke', 'Group Dining'],
      'images': ['assets/images/seoul_bbq.jpg', 'assets/images/seoul_interior.jpg'],
    },
    {
      'id': 'rest_004',
      'name': 'The Chocolate Factory',
      'cuisine': 'Desserts',
      'address': '321 Sweet St, Manhattan',
      'latitude': 40.7831,
      'longitude': -73.9712,
      'phone': '+1-555-0321',
      'website': 'www.chocolatefactory.com',
      'rating': 4.8,
      'reviewCount': 156,
      'priceRange': 'PP',
      'description': 'Artisanal chocolates and decadent desserts made fresh daily.',
      'imageUrl': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'hours': {
        'monday': '10:00-21:00',
        'tuesday': '10:00-21:00',
        'wednesday': '10:00-21:00',
        'thursday': '10:00-21:00',
        'friday': '10:00-22:00',
        'saturday': '09:00-22:00',
        'sunday': '10:00-20:00',
      },
      'features': ['Artisanal Chocolate', 'Custom Cakes', 'Coffee', 'Gift Shop'],
      'images': ['assets/images/chocolate_shop.jpg', 'assets/images/custom_cakes.jpg'],
    },
  ];

  // ========== MESSAGES ==========
  static final List<Map<String, dynamic>> messages = [
    {
      'id': 'msg_001',
      'conversationId': 'conv_001',
      'senderId': 'user_002',
      'receiverId': 'user_001',
      'text': 'Hey Sarah! Excited about the Italian food session tonight. Should we meet at 7 PM?',
      'timestamp': '2024-01-20T15:30:00Z',
      'isRead': true,
      'type': 'text', // text, image, location
    },
    {
      'id': 'msg_002',
      'conversationId': 'conv_001',
      'senderId': 'user_001',
      'receiverId': 'user_002',
      'text': 'Perfect! Looking forward to it. The truffle pasta there is amazing!',
      'timestamp': '2024-01-20T15:35:00Z',
      'isRead': true,
      'type': 'text',
    },
    {
      'id': 'msg_003',
      'conversationId': 'conv_002',
      'senderId': 'user_003',
      'receiverId': 'user_005',
      'text': 'Hi Lisa! I saw your chocolate cake post - it looks incredible! Any chance you\'d share the recipe? 😊',
      'timestamp': '2024-01-20T16:10:00Z',
      'isRead': false,
      'type': 'text',
    },
  ];

  // ========== CONVERSATIONS ==========
  static final List<Map<String, dynamic>> conversations = [
    {
      'id': 'conv_001',
      'participants': ['user_001', 'user_002'],
      'type': 'planning', // planning, friends, pending
      'sessionId': 'session_001',
      'lastMessage': 'Perfect! Looking forward to it. The truffle pasta there is amazing!',
      'lastMessageTime': '2024-01-20T15:35:00Z',
      'unreadCount': 0,
    },
    {
      'id': 'conv_002',
      'participants': ['user_003', 'user_005'],
      'type': 'friends',
      'sessionId': null,
      'lastMessage': 'Hi Lisa! I saw your chocolate cake post - it looks incredible!',
      'lastMessageTime': '2024-01-20T16:10:00Z',
      'unreadCount': 1,
    },
  ];

  // ========== REVIEWS ==========
  static final List<Map<String, dynamic>> reviews = [
    {
      'id': 'review_001',
      'reviewerId': 'user_002',
      'reviewedUserId': 'user_001',
      'sessionId': 'session_001',
      'rating': 5,
      'text': 'Sarah was an amazing dining companion! Great conversation and excellent restaurant choice. Would definitely join another session with her.',
      'timestamp': '2024-01-15T20:30:00Z',
      'isVisible': true,
    },
    {
      'id': 'review_002',
      'reviewerId': 'user_001',
      'reviewedUserId': 'user_004',
      'sessionId': 'session_002',
      'rating': 4,
      'text': 'David really knows his Korean food! Thanks for introducing me to some amazing dishes I\'d never tried before.',
      'timestamp': '2024-01-12T21:15:00Z',
      'isVisible': true,
    },
    {
      'id': 'review_003',
      'reviewerId': 'user_003',
      'reviewedUserId': 'user_005',
      'sessionId': null, // General review
      'rating': 5,
      'text': 'Lisa\'s passion for desserts is contagious! Always has great recommendations for sweet treats around the city.',
      'timestamp': '2024-01-08T14:45:00Z',
      'isVisible': true,
    },
  ];

  // ========== FOOD PREFERENCES & CUISINES ==========
  static final List<String> allFoodPreferences = [
    'Italian', 'Mexican', 'Chinese', 'Japanese', 'Korean', 'Thai', 'Vietnamese',
    'Indian', 'Mediterranean', 'French', 'American', 'BBQ', 'Seafood', 'Steakhouse',
    'Vegetarian', 'Vegan', 'Gluten-Free', 'Organic', 'Raw Foods', 'Keto',
    'Fast Food', 'Street Food', 'Food Trucks', 'Fine Dining', 'Casual Dining',
    'Pizza', 'Burgers', 'Sushi', 'Ramen', 'Pasta', 'Desserts', 'Ice Cream',
    'Coffee', 'Wine Bar', 'Craft Beer', 'Cocktails', 'Smoothies',
  ];

  static final List<String> dietaryRestrictions = [
    'None', 'Vegetarian', 'Vegan', 'Gluten-Free', 'Dairy-Free', 'Nut-Free',
    'Shellfish-Free', 'Kosher', 'Halal', 'Keto', 'Paleo', 'Low-Carb',
  ];

  // ========== HELPER METHODS ==========

  static Map<String, dynamic>? getUserById(String userId) {
    try {
      return users.firstWhere((user) => user['id'] == userId);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> getPostsByUserId(String userId) {
    return posts.where((post) => post['userId'] == userId).toList();
  }

  static List<Map<String, dynamic>> getSessionsByUserId(String userId) {
    return mealSessions.where((session) => session['hostUserId'] == userId).toList();
  }

  static List<Map<String, dynamic>> getReviewsForUser(String userId) {
    return reviews.where((review) =>
      review['reviewedUserId'] == userId && review['isVisible'] == true
    ).toList();
  }

  static List<Map<String, dynamic>> getFollowers(String userId) {
    List<Map<String, dynamic>> followers = [];
    followRelationships.forEach((followerId, followingList) {
      if (followingList.contains(userId)) {
        final follower = getUserById(followerId);
        if (follower != null) followers.add(follower);
      }
    });
    return followers;
  }

  static List<Map<String, dynamic>> getFollowing(String userId) {
    List<Map<String, dynamic>> following = [];
    final followingIds = followRelationships[userId] ?? [];
    for (String followingId in followingIds) {
      final user = getUserById(followingId);
      if (user != null) following.add(user);
    }
    return following;
  }

  static bool isUserFollowing(String currentUserId, String targetUserId) {
    final followingIds = followRelationships[currentUserId] ?? [];
    return followingIds.contains(targetUserId);
  }

  static List<Map<String, dynamic>> getCommentsForPost(String postId) {
    return comments.where((comment) => comment['postId'] == postId).toList();
  }

  static List<Map<String, dynamic>> getConversationsForUser(String userId) {
    return conversations.where((conv) =>
      (conv['participants'] as List).contains(userId)
    ).toList();
  }

  static List<Map<String, dynamic>> getMessagesForConversation(String conversationId) {
    return messages.where((msg) => msg['conversationId'] == conversationId).toList();
  }

  static Map<String, dynamic>? getRestaurantById(String restaurantId) {
    try {
      return restaurants.firstWhere((restaurant) => restaurant['id'] == restaurantId);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> searchUsers(String query) {
    if (query.isEmpty) return users;

    return users.where((user) =>
      user['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
      user['username'].toString().toLowerCase().contains(query.toLowerCase()) ||
      user['bio'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  static List<Map<String, dynamic>> getOpenSessions() {
    return mealSessions.where((session) => session['status'] == 'open').toList();
  }

  static List<Map<String, dynamic>> getRestaurantsByCuisine(String cuisine) {
    return restaurants.where((restaurant) =>
      restaurant['cuisine'].toString().toLowerCase().contains(cuisine.toLowerCase())
    ).toList();
  }

  // ========== MATCHES SCREEN HELPERS ==========

  static List<Map<String, dynamic>> getJoinRequestsForCurrentUser() {
    List<Map<String, dynamic>> requests = [];

    // Find all sessions hosted by current user
    final currentUserSessions = mealSessions.where(
      (session) => session['hostUserId'] == CurrentUser.userId
    ).toList();

    // For each session, get the pending users and create request objects
    for (final session in currentUserSessions) {
      final pendingUserIds = List<String>.from(session['pendingUsers'] ?? []);

      for (final userId in pendingUserIds) {
        final user = getUserById(userId);
        if (user != null) {
          requests.add({
            'id': 'request_${session['id']}_$userId',
            'sessionId': session['id'],
            'session': session,
            'user': user,
            'userId': userId,
            'requestedAt': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
            'status': 'pending', // pending, accepted, rejected
          });
        }
      }
    }

    return requests..sort((a, b) => b['requestedAt'].compareTo(a['requestedAt']));
  }

  static List<Map<String, dynamic>> getAcceptedJoinRequestsForCurrentUser() {
    List<Map<String, dynamic>> acceptedRequests = [];

    // Find all sessions hosted by current user
    final currentUserSessions = mealSessions.where(
      (session) => session['hostUserId'] == CurrentUser.userId
    ).toList();

    // For each session, get the joined users and create accepted request objects
    for (final session in currentUserSessions) {
      final joinedUserIds = List<String>.from(session['joinedUsers'] ?? []);

      for (final userId in joinedUserIds) {
        final user = getUserById(userId);
        if (user != null) {
          acceptedRequests.add({
            'id': 'accepted_${session['id']}_$userId',
            'sessionId': session['id'],
            'session': session,
            'user': user,
            'userId': userId,
            'acceptedAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
            'status': 'accepted',
          });
        }
      }
    }

    return acceptedRequests..sort((a, b) => b['acceptedAt'].compareTo(a['acceptedAt']));
  }

  static void acceptJoinRequest(String sessionId, String userId) {
    // Find the session
    final sessionIndex = mealSessions.indexWhere((s) => s['id'] == sessionId);
    if (sessionIndex == -1) return;

    final session = mealSessions[sessionIndex];

    // Move user from pending to joined
    final pendingUsers = List<String>.from(session['pendingUsers'] ?? []);
    final joinedUsers = List<String>.from(session['joinedUsers'] ?? []);

    if (pendingUsers.contains(userId)) {
      pendingUsers.remove(userId);
      joinedUsers.add(userId);

      // Update the session
      session['pendingUsers'] = pendingUsers;
      session['joinedUsers'] = joinedUsers;
      session['currentParticipants'] = joinedUsers.length;

      // Update the session in the list
      mealSessions[sessionIndex] = session;
    }
  }

  static void rejectJoinRequest(String sessionId, String userId) {
    // Find the session
    final sessionIndex = mealSessions.indexWhere((s) => s['id'] == sessionId);
    if (sessionIndex == -1) return;

    final session = mealSessions[sessionIndex];

    // Remove user from pending
    final pendingUsers = List<String>.from(session['pendingUsers'] ?? []);

    if (pendingUsers.contains(userId)) {
      pendingUsers.remove(userId);

      // Update the session
      session['pendingUsers'] = pendingUsers;

      // Update the session in the list
      mealSessions[sessionIndex] = session;
    }
  }
}

// ========== CURRENT USER SIMULATION ==========
class CurrentUser {
  static const String userId = 'user_001'; // Simulating Sarah Chen as current user

  static Map<String, dynamic> get currentUserData {
    return DummyData.getUserById(userId)!;
  }

  static List<Map<String, dynamic>> get currentUserPosts {
    return DummyData.getPostsByUserId(userId);
  }

  static List<Map<String, dynamic>> get currentUserSessions {
    return DummyData.getSessionsByUserId(userId);
  }

  static List<Map<String, dynamic>> get currentUserReviews {
    return DummyData.getReviewsForUser(userId);
  }

  static List<Map<String, dynamic>> get currentUserConversations {
    return DummyData.getConversationsForUser(userId);
  }
}