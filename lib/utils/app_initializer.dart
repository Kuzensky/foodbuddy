import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../services/firebase_service.dart';

class AppInitializer {
  static bool _isInitialized = false;

  /// Initialize the app with Firebase data
  static Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    try {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      final firebaseService = FirebaseService();

      // Check if user is authenticated
      if (firebaseService.currentUser != null) {
        print('🔐 User authenticated: ${firebaseService.currentUser!.email}');

        // Initialize data provider
        await dataProvider.initialize();

        // Check if database needs to be seeded
        if (!dataProvider.isDatabaseSeeded && dataProvider.restaurants.isEmpty) {
          print('🌱 Database appears empty, seeding with sample data...');
          await dataProvider.seedDatabase();
          print('✅ Database seeded successfully!');
        }

        // Update user online status
        await dataProvider.updateOnlineStatus(true);

        _isInitialized = true;
        print('🚀 App initialized successfully!');
      } else {
        print('❌ User not authenticated, skipping data initialization');
      }
    } catch (e) {
      print('❌ Error initializing app: $e');
      // Don't rethrow, just log the error
      // The app should still function with reduced functionality
    }
  }

  /// Reset initialization flag (for testing)
  static void reset() {
    _isInitialized = false;
  }

  /// Check if app is initialized
  static bool get isInitialized => _isInitialized;

  /// Show initialization dialog
  static void showInitializationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const InitializationDialog(),
    );
  }
}

class InitializationDialog extends StatefulWidget {
  const InitializationDialog({super.key});

  @override
  State<InitializationDialog> createState() => _InitializationDialogState();
}

class _InitializationDialogState extends State<InitializationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isComplete = false;
  String _currentStep = 'Connecting to Firebase...';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.repeat();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _currentStep = 'Connecting to Firebase...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _currentStep = 'Loading your data...');
      await AppInitializer.initialize(context);
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _currentStep = 'Preparing restaurants...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _currentStep = 'Setting up real-time updates...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _currentStep = 'Ready!';
        _isComplete = true;
      });
      _animationController.stop();

      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _currentStep = 'Error: $e';
        _isComplete = true;
      });
      _animationController.stop();

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Icon(
                    _isComplete
                        ? (_currentStep.startsWith('Error') ? Icons.error : Icons.check_circle)
                        : Icons.restaurant,
                    size: 48,
                    color: _isComplete
                        ? (_currentStep.startsWith('Error') ? Colors.red : Colors.green)
                        : Colors.black87,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'FoodBuddy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentStep,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (!_isComplete) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black87),
              ),
            ],
          ],
        ),
      ),
    );
  }
}