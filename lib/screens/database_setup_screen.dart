import 'package:flutter/material.dart';
import '../utils/manual_database_setup.dart';

class DatabaseSetupScreen extends StatefulWidget {
  const DatabaseSetupScreen({super.key});

  @override
  State<DatabaseSetupScreen> createState() => _DatabaseSetupScreenState();
}

class _DatabaseSetupScreenState extends State<DatabaseSetupScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Database Setup',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 80,
              color: Colors.black87,
            ),
            const SizedBox(height: 24),
            const Text(
              'Firebase Database Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Click the button below to populate your Firebase database with sample restaurants, users, meal sessions, and posts.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Status Container
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Setup Button
            ElevatedButton(
              onPressed: _isLoading ? null : _setupDatabase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Setting up database...'),
                      ],
                    )
                  : const Text(
                      'Setup Database',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // Clear Button
            OutlinedButton(
              onPressed: _isLoading ? null : _clearDatabase,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade600,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Clear All Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Spacer(),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will create:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 8 Restaurants in Batangas City\n'
                    '• 5 Sample Users\n'
                    '• 5 Meal Sessions\n'
                    '• 5 Social Posts\n'
                    '• Real-time data sync',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setupDatabase() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Starting database setup...';
    });

    try {
      setState(() => _statusMessage = 'Creating restaurants...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _statusMessage = 'Adding sample users...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _statusMessage = 'Creating meal sessions...');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() => _statusMessage = 'Adding social posts...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Run the actual setup
      await ManualDatabaseSetup.setupDatabase();

      setState(() {
        _statusMessage = '✅ Database setup completed successfully!\n\n'
            'Check your Firebase console to see all the new collections:\n'
            '• restaurants\n'
            '• users\n'
            '• meal_sessions\n'
            '• posts\n\n'
            'You can now use the app with real data!';
      });

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: const Text(
              'Your Firebase database has been populated with sample data. '
              'You should now see all collections in your Firebase console.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error setting up database: $e\n\n'
            'Please check your Firebase configuration and internet connection.';
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to setup database: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearDatabase() async {
    // Show confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Database?'),
        content: const Text(
          'This will permanently delete ALL data from your Firebase database. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing all data...';
    });

    try {
      await ManualDatabaseSetup.clearAllData();

      setState(() {
        _statusMessage = '✅ All data cleared successfully!\n\n'
            'Your Firebase database is now empty. '
            'You can run setup again to add sample data.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error clearing database: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}