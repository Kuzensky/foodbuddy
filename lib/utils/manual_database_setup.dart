import 'package:cloud_firestore/cloud_firestore.dart';

/// Manual database setup script - Run this once to populate your Firebase database
class ManualDatabaseSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Run this method to manually populate your Firebase database
  static Future<void> setupDatabase() async {
    print('🚀 Starting manual database setup...');

    try {
      await _createRestaurants();
      await _createSampleUsers();
      await _createMealSessions();
      await _createPosts();

      print('✅ Database setup completed successfully!');
      print('🔥 You should now see all collections in your Firebase console');
    } catch (e) {
      print('❌ Error setting up database: $e');
      rethrow;
    }
  }

  /// Create restaurants collection
  static Future<void> _createRestaurants() async {
    print('🍽️ Creating restaurants...');

    final restaurants = [
      {
        'name': 'Giovanni\'s Italian Restaurant',
        'cuisine': 'Italian',
        'address': 'P. Burgos St, Alangilan, Batangas City',
        'latitude': 13.7659,
        'longitude': 121.0581,
        'phone': '+63-43-555-0123',
        'website': 'www.giovannis.com',
        'rating': 4.5,
        'reviewCount': 247,
        'priceRange': '₱₱',
        'description': 'Authentic Italian cuisine with traditional recipes passed down through generations.',
        'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=1200&q=85',
        'hours': {
          'monday': '11:00-22:00',
          'tuesday': '11:00-22:00',
          'wednesday': '11:00-22:00',
          'thursday': '11:00-22:00',
          'friday': '11:00-23:00',
          'saturday': '11:00-23:00',
          'sunday': '12:00-21:00',
        },
        'features': ['Outdoor Seating', 'Wine Bar', 'Reservations', 'Romantic'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Green Leaf Café',
        'cuisine': 'Vegan',
        'address': '123 Kumintang Ilaya, Batangas City',
        'latitude': 13.7665,
        'longitude': 121.0590,
        'phone': '+63-43-555-0456',
        'website': 'www.greenleafcafe.com',
        'rating': 4.7,
        'reviewCount': 189,
        'priceRange': '₱',
        'description': 'Fresh, organic, plant-based meals that nourish both body and soul.',
        'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200&q=85',
        'hours': {
          'monday': '07:00-20:00',
          'tuesday': '07:00-20:00',
          'wednesday': '07:00-20:00',
          'thursday': '07:00-20:00',
          'friday': '07:00-21:00',
          'saturday': '08:00-21:00',
          'sunday': '08:00-19:00',
        },
        'features': ['Vegan Only', 'Organic', 'Smoothies', 'WiFi', 'Healthy'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Seoul Kitchen',
        'cuisine': 'Korean',
        'address': '456 Hilltop, Batangas City',
        'latitude': 13.7650,
        'longitude': 121.0575,
        'phone': '+63-43-555-0789',
        'website': 'www.seoulkitchen.com',
        'rating': 4.4,
        'reviewCount': 312,
        'priceRange': '₱₱',
        'description': 'Traditional Korean BBQ and authentic dishes in a modern setting.',
        'imageUrl': 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=1200&q=85',
        'hours': {
          'monday': 'Closed',
          'tuesday': '17:00-23:00',
          'wednesday': '17:00-23:00',
          'thursday': '17:00-23:00',
          'friday': '17:00-24:00',
          'saturday': '16:00-24:00',
          'sunday': '16:00-22:00',
        },
        'features': ['Korean BBQ', 'Private Rooms', 'Karaoke', 'Group Dining', 'Spicy'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'The Chocolate Factory',
        'cuisine': 'Desserts',
        'address': '789 Pallocan West, Batangas City',
        'latitude': 13.7670,
        'longitude': 121.0595,
        'phone': '+63-43-555-0321',
        'website': 'www.chocolatefactory.com',
        'rating': 4.8,
        'reviewCount': 156,
        'priceRange': '₱₱',
        'description': 'Artisanal chocolates and decadent desserts made fresh daily.',
        'imageUrl': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=1200&q=85',
        'hours': {
          'monday': '10:00-21:00',
          'tuesday': '10:00-21:00',
          'wednesday': '10:00-21:00',
          'thursday': '10:00-21:00',
          'friday': '10:00-22:00',
          'saturday': '09:00-22:00',
          'sunday': '10:00-20:00',
        },
        'features': ['Artisanal Chocolate', 'Custom Cakes', 'Coffee', 'Gift Shop', 'Sweet'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Sakura Sushi Bar',
        'cuisine': 'Japanese',
        'address': '321 Poblacion, Batangas City',
        'latitude': 13.7580,
        'longitude': 121.0540,
        'phone': '+63-43-555-0654',
        'website': 'www.sakurasushi.com',
        'rating': 4.6,
        'reviewCount': 198,
        'priceRange': '₱₱₱',
        'description': 'Fresh sushi and authentic Japanese cuisine.',
        'imageUrl': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=1200&q=85',
        'hours': {
          'monday': '11:30-14:30,17:30-22:00',
          'tuesday': '11:30-14:30,17:30-22:00',
          'wednesday': '11:30-14:30,17:30-22:00',
          'thursday': '11:30-14:30,17:30-22:00',
          'friday': '11:30-14:30,17:30-23:00',
          'saturday': '12:00-23:00',
          'sunday': '12:00-21:00',
        },
        'features': ['Fresh Sushi', 'Sake Bar', 'Omakase', 'Sashimi'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Taco Libre',
        'cuisine': 'Mexican',
        'address': '654 Calicanto, Batangas City',
        'latitude': 13.7620,
        'longitude': 121.0560,
        'phone': '+63-43-555-0987',
        'website': 'www.tacolibre.com',
        'rating': 4.3,
        'reviewCount': 164,
        'priceRange': '₱',
        'description': 'Authentic Mexican street food and traditional dishes.',
        'imageUrl': 'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=1200&q=85',
        'hours': {
          'monday': '11:00-21:00',
          'tuesday': '11:00-21:00',
          'wednesday': '11:00-21:00',
          'thursday': '11:00-21:00',
          'friday': '11:00-22:00',
          'saturday': '10:00-22:00',
          'sunday': '10:00-20:00',
        },
        'features': ['Street Food', 'Spicy', 'Casual', 'Takeout'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Curry Palace',
        'cuisine': 'Indian',
        'address': '987 Malvar, Batangas City',
        'latitude': 13.7640,
        'longitude': 121.0520,
        'phone': '+63-43-555-0147',
        'website': 'www.currypalace.com',
        'rating': 4.5,
        'reviewCount': 203,
        'priceRange': '₱₱',
        'description': 'Aromatic spices and authentic Indian cuisine.',
        'imageUrl': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=1200&q=85',
        'hours': {
          'monday': '11:00-15:00,17:00-22:00',
          'tuesday': '11:00-15:00,17:00-22:00',
          'wednesday': '11:00-15:00,17:00-22:00',
          'thursday': '11:00-15:00,17:00-22:00',
          'friday': '11:00-15:00,17:00-23:00',
          'saturday': '11:00-23:00',
          'sunday': '11:00-21:00',
        },
        'features': ['Spicy', 'Vegetarian Options', 'Halal', 'Curry'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Burger Junction',
        'cuisine': 'American',
        'address': '159 Tabangao, Batangas City',
        'latitude': 13.7600,
        'longitude': 121.0600,
        'phone': '+63-43-555-0753',
        'website': 'www.burgerjunction.com',
        'rating': 4.2,
        'reviewCount': 298,
        'priceRange': '₱',
        'description': 'Juicy burgers and classic American comfort food.',
        'imageUrl': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=1200&q=85',
        'hours': {
          'monday': '10:00-22:00',
          'tuesday': '10:00-22:00',
          'wednesday': '10:00-22:00',
          'thursday': '10:00-22:00',
          'friday': '10:00-23:00',
          'saturday': '10:00-23:00',
          'sunday': '11:00-21:00',
        },
        'features': ['Fast Food', 'Burgers', 'Fries', 'Milkshakes'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    // Add restaurants to Firestore
    final batch = _firestore.batch();
    for (int i = 0; i < restaurants.length; i++) {
      final docRef = _firestore.collection('restaurants').doc('rest_00${i + 1}');
      batch.set(docRef, restaurants[i]);
    }
    await batch.commit();
    print('✅ Added ${restaurants.length} restaurants');
  }

  /// Create sample users
  static Future<void> _createSampleUsers() async {
    print('👥 Creating sample users...');

    final users = [
      {
        'uid': 'sample_user_001',
        'name': 'Sarah Chen',
        'username': 'sarahc',
        'email': 'sarah.chen@example.com',
        'bio': 'Food enthusiast who loves exploring new cuisines and meeting fellow food lovers!',
        'location': 'Alangilan, Batangas City',
        'age': 28,
        'profilePicture': null,
        'isVerified': true,
        'isEmailVerified': true,
        'postsCount': 24,
        'followersCount': 342,
        'followingCount': 186,
        'rating': 4.8,
        'foodPreferences': ['Italian', 'Vegetarian', 'Asian Cuisine', 'Gluten-Free'],
        'interests': ['Fine Dining', 'Cooking', 'Food Photography'],
        'isOnline': true,
        'joinedDate': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'sample_user_002',
        'name': 'Mike Johnson',
        'username': 'mikej',
        'email': 'mike.johnson@example.com',
        'bio': 'Home chef and restaurant reviewer. Love sharing my culinary adventures!',
        'location': 'Kumintang Ilaya, Batangas City',
        'age': 32,
        'profilePicture': null,
        'isVerified': false,
        'isEmailVerified': true,
        'postsCount': 18,
        'followersCount': 256,
        'followingCount': 94,
        'rating': 4.6,
        'foodPreferences': ['BBQ', 'Mexican Food', 'Craft Beer', 'Seafood'],
        'interests': ['Home Cooking', 'Food Reviews', 'Beer Tasting'],
        'isOnline': false,
        'joinedDate': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'sample_user_003',
        'name': 'Emma Rodriguez',
        'username': 'emmar',
        'email': 'emma.rodriguez@example.com',
        'bio': 'Foodie and travel blogger exploring the world one bite at a time. Vegan lifestyle advocate.',
        'location': 'Pallocan West, Batangas City',
        'age': 26,
        'profilePicture': null,
        'isVerified': true,
        'isEmailVerified': true,
        'postsCount': 45,
        'followersCount': 512,
        'followingCount': 203,
        'rating': 4.9,
        'foodPreferences': ['Vegan', 'Organic', 'Raw Foods', 'Mediterranean'],
        'interests': ['Travel', 'Food Blogging', 'Sustainable Eating'],
        'isOnline': true,
        'joinedDate': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'sample_user_004',
        'name': 'David Kim',
        'username': 'davidk',
        'email': 'david.kim@example.com',
        'bio': 'Korean food specialist and culinary student. Always excited to share authentic recipes!',
        'location': 'Hilltop, Batangas City',
        'age': 24,
        'profilePicture': null,
        'isVerified': false,
        'isEmailVerified': true,
        'postsCount': 31,
        'followersCount': 189,
        'followingCount': 142,
        'rating': 4.7,
        'foodPreferences': ['Korean', 'Asian Fusion', 'Spicy Food', 'Street Food'],
        'interests': ['Culinary Arts', 'Recipe Development', 'Food Culture'],
        'isOnline': true,
        'joinedDate': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'uid': 'sample_user_005',
        'name': 'Lisa Thompson',
        'username': 'lisath',
        'email': 'lisa.thompson@example.com',
        'bio': 'Pastry chef and dessert lover. Creating sweet memories one dessert at a time!',
        'location': 'Poblacion, Batangas City',
        'age': 29,
        'profilePicture': null,
        'isVerified': true,
        'isEmailVerified': true,
        'postsCount': 52,
        'followersCount': 678,
        'followingCount': 234,
        'rating': 4.9,
        'foodPreferences': ['Desserts', 'French Pastry', 'Chocolate', 'Coffee'],
        'interests': ['Baking', 'Pastry Arts', 'Coffee Culture'],
        'isOnline': false,
        'joinedDate': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    // Add users to Firestore
    final batch = _firestore.batch();
    for (final user in users) {
      final docRef = _firestore.collection('users').doc(user['uid'] as String);
      batch.set(docRef, user);
    }
    await batch.commit();
    print('✅ Added ${users.length} sample users');
  }

  /// Create meal sessions
  static Future<void> _createMealSessions() async {
    print('🍽️ Creating meal sessions...');

    final now = DateTime.now();
    final sessions = [
      {
        'hostUserId': 'sample_user_001',
        'title': 'Italian Food Tasting Night',
        'description': 'Looking for fellow Italian food lovers to explore authentic dishes at Giovanni\'s!',
        'restaurantId': 'rest_001',
        'scheduledTime': Timestamp.fromDate(now.add(const Duration(days: 2))),
        'maxParticipants': 4,
        'currentParticipants': 2,
        'status': 'open',
        'preferences': {
          'ageRange': [25, 35],
          'foodTypes': ['Italian', 'Wine'],
          'dietaryRestrictions': ['No Nuts'],
          'priceRange': [30, 60],
        },
        'joinedUsers': ['sample_user_001', 'sample_user_003'],
        'pendingUsers': ['sample_user_002'],
        'rejectedUsers': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'hostUserId': 'sample_user_004',
        'title': 'Korean BBQ Experience',
        'description': 'Join me for an authentic Korean BBQ experience!',
        'restaurantId': 'rest_003',
        'scheduledTime': Timestamp.fromDate(now.add(const Duration(days: 3))),
        'maxParticipants': 6,
        'currentParticipants': 3,
        'status': 'open',
        'preferences': {
          'ageRange': [22, 40],
          'foodTypes': ['Korean', 'Spicy', 'Meat'],
          'dietaryRestrictions': [],
          'priceRange': [25, 50],
        },
        'joinedUsers': ['sample_user_004', 'sample_user_001', 'sample_user_002'],
        'pendingUsers': [],
        'rejectedUsers': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'hostUserId': 'sample_user_003',
        'title': 'Vegan Brunch Meetup',
        'description': 'Calling all plant-based food lovers! Let\'s enjoy a delicious vegan brunch together.',
        'restaurantId': 'rest_002',
        'scheduledTime': Timestamp.fromDate(now.add(const Duration(days: 4))),
        'maxParticipants': 5,
        'currentParticipants': 2,
        'status': 'open',
        'preferences': {
          'ageRange': [20, 45],
          'foodTypes': ['Vegan', 'Organic', 'Healthy'],
          'dietaryRestrictions': ['Vegan Only'],
          'priceRange': [15, 35],
        },
        'joinedUsers': ['sample_user_003', 'sample_user_005'],
        'pendingUsers': ['sample_user_001'],
        'rejectedUsers': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'hostUserId': 'sample_user_005',
        'title': 'Dessert Lovers Unite',
        'description': 'Sweet tooths unite! Let\'s explore amazing desserts at The Chocolate Factory.',
        'restaurantId': 'rest_004',
        'scheduledTime': Timestamp.fromDate(now.add(const Duration(days: 5))),
        'maxParticipants': 4,
        'currentParticipants': 1,
        'status': 'open',
        'preferences': {
          'ageRange': [21, 50],
          'foodTypes': ['Desserts', 'Chocolate', 'Coffee'],
          'dietaryRestrictions': [],
          'priceRange': [20, 40],
        },
        'joinedUsers': ['sample_user_005'],
        'pendingUsers': ['sample_user_003', 'sample_user_004'],
        'rejectedUsers': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'hostUserId': 'sample_user_002',
        'title': 'Sushi & Sake Night',
        'description': 'Join me for fresh sushi and premium sake at Sakura Sushi Bar.',
        'restaurantId': 'rest_005',
        'scheduledTime': Timestamp.fromDate(now.add(const Duration(days: 6))),
        'maxParticipants': 3,
        'currentParticipants': 1,
        'status': 'open',
        'preferences': {
          'ageRange': [25, 45],
          'foodTypes': ['Japanese', 'Sushi', 'Sake'],
          'dietaryRestrictions': [],
          'priceRange': [40, 80],
        },
        'joinedUsers': ['sample_user_002'],
        'pendingUsers': ['sample_user_001', 'sample_user_004'],
        'rejectedUsers': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    // Add sessions to Firestore
    for (final session in sessions) {
      await _firestore.collection('meal_sessions').add(session);
    }
    print('✅ Added ${sessions.length} meal sessions');
  }

  /// Create sample posts
  static Future<void> _createPosts() async {
    print('📸 Creating posts...');

    final now = DateTime.now();
    final posts = [
      {
        'userId': 'sample_user_001',
        'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&q=85',
        'caption': 'Amazing truffle pasta at Giovanni\'s! The flavor combination was absolutely perfect. 🍝✨',
        'location': 'Giovanni\'s Italian Restaurant, Alangilan',
        'restaurantId': 'rest_001',
        'hashtags': ['#ItalianFood', '#TrufflePasta', '#Foodie', '#BatangasEats'],
        'likesCount': 42,
        'commentsCount': 8,
        'sharesCount': 3,
        'likedBy': ['sample_user_002', 'sample_user_003', 'sample_user_005'],
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 2))),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'sample_user_002',
        'imageUrl': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&q=85',
        'caption': 'Perfect BBQ burger at Burger Junction! Juicy patty, crispy bacon, and their secret sauce. 🍔',
        'location': 'Burger Junction, Tabangao',
        'restaurantId': 'rest_008',
        'hashtags': ['#Burger', '#BBQ', '#ComfortFood', '#Delicious'],
        'likesCount': 67,
        'commentsCount': 12,
        'sharesCount': 5,
        'likedBy': ['sample_user_001', 'sample_user_004', 'sample_user_005'],
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 5))),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'sample_user_003',
        'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=85',
        'caption': 'Colorful Buddha bowl packed with nutrients! Quinoa, roasted veggies, and tahini dressing. 🌱',
        'location': 'Green Leaf Café, Kumintang Ilaya',
        'restaurantId': 'rest_002',
        'hashtags': ['#VeganFood', '#BuddhaBowl', '#PlantBased', '#Healthy'],
        'likesCount': 89,
        'commentsCount': 15,
        'sharesCount': 7,
        'likedBy': ['sample_user_001', 'sample_user_004', 'sample_user_005'],
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(hours: 8))),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'sample_user_004',
        'imageUrl': 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=800&q=85',
        'caption': 'Traditional Korean BBQ night with friends! The kimchi was especially amazing tonight! 🥢',
        'location': 'Seoul Kitchen, Hilltop',
        'restaurantId': 'rest_003',
        'hashtags': ['#KoreanBBQ', '#FriendsTime', '#Kimchi', '#Traditional'],
        'likesCount': 56,
        'commentsCount': 9,
        'sharesCount': 2,
        'likedBy': ['sample_user_002', 'sample_user_003'],
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': 'sample_user_005',
        'imageUrl': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=85',
        'caption': 'Triple chocolate layer cake I made for a special celebration! Pure indulgence! 🍰',
        'location': 'The Chocolate Factory, Pallocan West',
        'restaurantId': 'rest_004',
        'hashtags': ['#ChocolateCake', '#Homemade', '#Dessert', '#Celebration'],
        'likesCount': 134,
        'commentsCount': 23,
        'sharesCount': 11,
        'likedBy': ['sample_user_001', 'sample_user_002', 'sample_user_003', 'sample_user_004'],
        'createdAt': Timestamp.fromDate(now.subtract(const Duration(days: 1, hours: 4))),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    // Add posts to Firestore
    for (final post in posts) {
      await _firestore.collection('posts').add(post);
    }
    print('✅ Added ${posts.length} posts');
  }

  /// Clear all data (for testing)
  static Future<void> clearAllData() async {
    print('🗑️ Clearing all data...');

    final collections = ['restaurants', 'users', 'meal_sessions', 'posts', 'conversations', 'followers', 'following'];

    for (final collectionName in collections) {
      final snapshot = await _firestore.collection(collectionName).get();
      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }
      print('✅ Cleared collection: $collectionName');
    }

    print('✅ All data cleared successfully!');
  }
}