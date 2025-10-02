import 'package:flutter/foundation.dart';
import '../services/database_service.dart';

/// Utility script to clear social data from Firestore
/// Run this to clean up posts, likes, follows, notifications, and messages
/// while keeping restaurants and user profiles intact
class ClearSocialDataUtility {
  static Future<void> clearAllSocialData() async {
    try {
      if (kDebugMode) {
        debugPrint('🧹 STARTING SOCIAL DATA CLEANUP...');
        debugPrint('This will delete:');
        debugPrint('  - Posts');
        debugPrint('  - Likes');
        debugPrint('  - Follows');
        debugPrint('  - Notifications');
        debugPrint('  - Messages');
        debugPrint('  - Reset user social counts');
        debugPrint('');
        debugPrint('This will KEEP:');
        debugPrint('  - Users');
        debugPrint('  - Restaurants');
        debugPrint('  - Meal sessions');
        debugPrint('');
      }

      final databaseService = DatabaseService();
      await databaseService.clearSocialFeedData();

      if (kDebugMode) {
        debugPrint('✅ SOCIAL DATA CLEANUP COMPLETED SUCCESSFULLY!');
        debugPrint('The database is now clean and ready for fresh social content.');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ERROR DURING SOCIAL DATA CLEANUP: $e');
      }
      rethrow;
    }
  }
}

/// Quick method to execute the cleanup
/// Call this from anywhere in your app
Future<void> executeSocialDataCleanup() async {
  await ClearSocialDataUtility.clearAllSocialData();
}

/// Temporary main method to execute cleanup directly
/// Uncomment and run this file when you need to clear social data
void main() async {
  await executeSocialDataCleanup();
}