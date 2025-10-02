import 'package:firebase_core/firebase_core.dart';
import '../lib/utils/clear_social_data.dart';

/// Standalone script to clear social data from Firestore
/// Run with: flutter run scripts/clear_social_data.dart
Future<void> main() async {
  print('🔥 Initializing Firebase...');
  await Firebase.initializeApp();

  print('🧹 Starting social data cleanup...');
  await executeSocialDataCleanup();

  print('✅ Cleanup completed! Exiting...');
}