import 'package:flutter/foundation.dart';

/// Professional logging utility for FoodBuddy application
/// Provides structured logging with different levels and proper debug mode handling
class AppLogger {
  /// Debug level logging - for development debugging
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('🐛 ${formattedTag}$message');
    }
  }

  /// Info level logging - for general application flow
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('ℹ️ ${formattedTag}$message');
    }
  }

  /// Warning level logging - for potential issues
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('⚠️ ${formattedTag}$message');
    }
  }

  /// Error level logging - for errors and exceptions
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('❌ ${formattedTag}$message');
      if (error != null) {
        debugPrint('   Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('   Stack trace: $stackTrace');
      }
    }
  }

  /// Success level logging - for successful operations
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('✅ ${formattedTag}$message');
    }
  }

  /// Network level logging - for API calls and responses
  static void network(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('🌐 ${formattedTag}$message');
    }
  }

  /// Database level logging - for database operations
  static void database(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('🗄️ ${formattedTag}$message');
    }
  }

  /// UI level logging - for user interface events
  static void ui(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('🎨 ${formattedTag}$message');
    }
  }

  /// Performance level logging - for performance monitoring
  static void performance(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('⚡ ${formattedTag}$message');
    }
  }

  /// Auth level logging - for authentication operations
  static void auth(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedTag = tag != null ? '[$tag] ' : '';
      debugPrint('🔐 ${formattedTag}$message');
    }
  }
}

/// Extension to add logging functionality to any class
extension LoggerExtension on Object {
  /// Get class name for logging
  String get _className => runtimeType.toString();

  /// Log debug message with class name as tag
  void logDebug(String message) => AppLogger.debug(message, _className);

  /// Log info message with class name as tag
  void logInfo(String message) => AppLogger.info(message, _className);

  /// Log warning message with class name as tag
  void logWarning(String message) => AppLogger.warning(message, _className);

  /// Log error message with class name as tag
  void logError(String message, [Object? error, StackTrace? stackTrace]) =>
      AppLogger.error(message, error, stackTrace, _className);

  /// Log success message with class name as tag
  void logSuccess(String message) => AppLogger.success(message, _className);

  /// Log database operation with class name as tag
  void logDatabase(String message) => AppLogger.database(message, _className);

  /// Log UI event with class name as tag
  void logUI(String message) => AppLogger.ui(message, _className);

  /// Log network operation with class name as tag
  void logNetwork(String message) => AppLogger.network(message, _className);

  /// Log auth operation with class name as tag
  void logAuth(String message) => AppLogger.auth(message, _className);

  /// Log performance metric with class name as tag
  void logPerformance(String message) => AppLogger.performance(message, _className);
}