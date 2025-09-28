# 🔥 Firebase Database Setup Guide for FoodBuddy

This guide will help you set up Firebase Firestore for your FoodBuddy app with real-time data and automatic seeding.

## 🏗️ Database Architecture

### **Collections Structure**

```
📁 foodbuddy-firestore/
├── 👥 users/
│   ├── [uid]/
│   │   ├── uid: string
│   │   ├── name: string
│   │   ├── email: string
│   │   ├── username: string
│   │   ├── bio: string
│   │   ├── location: string
│   │   ├── profilePicture: string?
│   │   ├── isVerified: boolean
│   │   ├── isEmailVerified: boolean
│   │   ├── postsCount: number
│   │   ├── followersCount: number
│   │   ├── followingCount: number
│   │   ├── rating: number
│   │   ├── age: number?
│   │   ├── foodPreferences: array<string>
│   │   ├── interests: array<string>
│   │   ├── isOnline: boolean
│   │   ├── joinedDate: timestamp
│   │   ├── lastSeen: timestamp
│   │   ├── createdAt: timestamp
│   │   └── updatedAt: timestamp
│   └── ...
├── 🍽️ restaurants/
│   ├── [restaurantId]/
│   │   ├── name: string
│   │   ├── cuisine: string
│   │   ├── address: string
│   │   ├── latitude: number
│   │   ├── longitude: number
│   │   ├── phone: string
│   │   ├── website: string
│   │   ├── rating: number
│   │   ├── reviewCount: number
│   │   ├── priceRange: string (₱, ₱₱, ₱₱₱, ₱₱₱₱)
│   │   ├── description: string
│   │   ├── imageUrl: string
│   │   ├── hours: map<string, string>
│   │   ├── features: array<string>
│   │   ├── isActive: boolean
│   │   ├── createdAt: timestamp
│   │   └── updatedAt: timestamp
│   └── ...
├── 🎯 meal_sessions/
│   ├── [sessionId]/
│   │   ├── hostUserId: string
│   │   ├── title: string
│   │   ├── description: string
│   │   ├── restaurantId: string
│   │   ├── scheduledTime: timestamp
│   │   ├── maxParticipants: number
│   │   ├── currentParticipants: number
│   │   ├── status: string (open, full, completed, cancelled)
│   │   ├── preferences: map
│   │   │   ├── ageRange: array<number>
│   │   │   ├── foodTypes: array<string>
│   │   │   ├── dietaryRestrictions: array<string>
│   │   │   └── priceRange: array<number>
│   │   ├── joinedUsers: array<string>
│   │   ├── pendingUsers: array<string>
│   │   ├── rejectedUsers: array<string>
│   │   ├── createdAt: timestamp
│   │   └── updatedAt: timestamp
│   └── ...
├── 📸 posts/
│   ├── [postId]/
│   │   ├── userId: string
│   │   ├── imageUrl: string?
│   │   ├── caption: string
│   │   ├── location: string?
│   │   ├── restaurantId: string?
│   │   ├── hashtags: array<string>
│   │   ├── likesCount: number
│   │   ├── commentsCount: number
│   │   ├── sharesCount: number
│   │   ├── likedBy: array<string>
│   │   ├── createdAt: timestamp
│   │   └── updatedAt: timestamp
│   └── ...
├── 💬 conversations/
│   ├── [conversationId]/
│   │   ├── participants: array<string>
│   │   ├── lastMessage: string
│   │   ├── lastMessageTime: timestamp
│   │   ├── unreadCount: map<string, number>
│   │   ├── createdAt: timestamp
│   │   ├── updatedAt: timestamp
│   │   └── 📁 messages/
│   │       ├── [messageId]/
│   │       │   ├── senderId: string
│   │       │   ├── receiverId: string
│   │       │   ├── text: string
│   │       │   ├── type: string (text, image, location)
│   │       │   ├── isRead: boolean
│   │       │   └── createdAt: timestamp
│   │       └── ...
│   └── ...
├── 👥 followers/
│   ├── [userId]/
│   │   └── users: array<string>
│   └── ...
└── 👤 following/
    ├── [userId]/
    │   └── users: array<string>
    └── ...
```

## 🚀 Quick Setup

### 1. **Firebase Project Setup**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Enable **Firestore Database**
4. Enable **Authentication** (Email/Password & Google)
5. Download `google-services.json` and place in `android/app/`

### 2. **Firestore Security Rules**

In Firebase Console → Firestore Database → Rules, paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if true; // Users can read any profile
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Restaurants collection (read-only for users)
    match /restaurants/{restaurantId} {
      allow read: if true;
      allow write: if false; // Only admins can modify restaurants
    }

    // Meal sessions
    match /meal_sessions/{sessionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == resource.data.hostUserId;
      allow update: if request.auth != null && (
        request.auth.uid == resource.data.hostUserId ||
        request.auth.uid in resource.data.joinedUsers ||
        request.auth.uid in resource.data.pendingUsers
      );
      allow delete: if request.auth != null && request.auth.uid == resource.data.hostUserId;
    }

    // Posts
    match /posts/{postId} {
      allow read: if true; // Public posts
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && (
        request.auth.uid == resource.data.userId ||
        request.fieldPaths.hasOnly(['likesCount', 'likedBy', 'commentsCount'])
      );
      allow delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }

    // Conversations
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && request.auth.uid in resource.data.participants;

      // Messages subcollection
      match /messages/{messageId} {
        allow read, write: if request.auth != null && request.auth.uid in get(/databases/$(database)/documents/conversations/$(conversationId)).data.participants;
      }
    }

    // Followers/Following
    match /followers/{userId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /following/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3. **Enable Authentication**

1. Go to Authentication → Sign-in method
2. Enable **Email/Password**
3. Enable **Google** (optional)

### 4. **App Configuration**

The app will automatically:
- ✅ Initialize Firebase on first run
- ✅ Seed the database with sample data
- ✅ Set up real-time listeners
- ✅ Create sample restaurants in Batangas City area

## 🎯 Features Implemented

### **Real-time Data Sync**
- 🔄 Live updates for meal sessions
- 🔄 Real-time messaging
- 🔄 Instant notification of join requests
- 🔄 Live post feed updates

### **Restaurant Data**
- 📍 8 sample restaurants in Batangas City with real coordinates
- 🍽️ Multiple cuisines: Italian, Korean, Vegan, Japanese, Mexican, Indian, American, Desserts
- ⭐ Ratings, reviews, and operating hours
- 💰 Price range indicators (₱ to ₱₱₱₱)

### **Meal Sessions**
- 👥 Create and join meal sessions
- ⏰ Scheduled dining times
- 🎯 Preference matching (age, cuisine, budget)
- 📝 Join request management
- 💬 Session-based messaging

### **Social Features**
- 📸 Photo posts with captions
- ❤️ Like and comment system
- 👥 Follow/unfollow users
- 🔍 User search
- 📱 Real-time activity feed

## 🧪 Testing Data

### **Sample Users**
- **Sarah Chen** - Italian food enthusiast
- **Mike Johnson** - BBQ and beer lover
- **Emma Rodriguez** - Vegan lifestyle advocate
- **David Kim** - Korean food specialist
- **Lisa Thompson** - Pastry chef and dessert lover

### **Sample Restaurants**
All located in Batangas City with real coordinates:

1. **Giovanni's Italian Restaurant** - Alangilan (₱₱)
2. **Green Leaf Café** - Kumintang Ilaya (₱) - Vegan
3. **Seoul Kitchen** - Hilltop (₱₱) - Korean BBQ
4. **The Chocolate Factory** - Pallocan West (₱₱) - Desserts
5. **Sakura Sushi Bar** - Poblacion (₱₱₱) - Japanese
6. **Taco Libre** - Calicanto (₱) - Mexican
7. **Curry Palace** - Malvar (₱₱) - Indian
8. **Burger Junction** - Tabangao (₱) - American

## 🔧 Manual Database Operations

### **Seed Database**
```dart
// In your app, call this once
final dataProvider = Provider.of<DataProvider>(context, listen: false);
await dataProvider.seedDatabase();
```

### **Clear Database** (for testing)
```dart
final dataProvider = Provider.of<DataProvider>(context, listen: false);
await dataProvider.clearDatabase();
```

### **Check Initialization**
```dart
if (AppInitializer.isInitialized) {
  print('App is ready!');
}
```

## 🎛️ Database Indexing

For optimal performance, create these indexes in Firestore:

1. **meal_sessions**: `hostUserId` (ASC), `scheduledTime` (ASC)
2. **meal_sessions**: `joinedUsers` (ARRAY), `scheduledTime` (ASC)
3. **posts**: `createdAt` (DESC)
4. **posts**: `userId` (ASC), `createdAt` (DESC)
5. **conversations**: `participants` (ARRAY), `lastMessageTime` (DESC)

## 🐛 Troubleshooting

### **"Permission denied" errors**
- Check Firestore security rules
- Ensure user is authenticated
- Verify field names match rules

### **"No data showing" issues**
1. Check internet connection
2. Verify Firebase project configuration
3. Run seed database function
4. Check console for error messages

### **Authentication issues**
- Enable required sign-in methods in Firebase Console
- Check `google-services.json` is in correct location
- Verify package name matches Firebase project

## 📱 Usage

1. **Sign up/Login** - App will automatically initialize data
2. **Discover** - Browse open meal sessions from real restaurants
3. **Join Sessions** - Send join requests to session hosts
4. **Matches** - Manage incoming requests and active sessions
5. **Social** - Post photos, like content, follow users
6. **Messaging** - Chat with session participants

## 🔄 Real-time Updates

The app provides real-time updates for:
- New meal sessions in discover feed
- Join requests and acceptances
- Message notifications
- Post likes and comments
- User online/offline status

All data syncs automatically across devices! 🎉

---

**Need help?** Check the console logs for detailed initialization steps and error messages.