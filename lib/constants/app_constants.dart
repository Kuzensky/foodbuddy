/// Application-wide constants for FoodBuddy
/// Centralizes all magic numbers, durations, and configuration values
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ==================== ANIMATION DURATIONS ====================

  /// Short animation duration for quick transitions
  static const Duration shortAnimation = Duration(milliseconds: 300);

  /// Medium animation duration for standard transitions
  static const Duration mediumAnimation = Duration(milliseconds: 600);

  /// Long animation duration for complex transitions
  static const Duration longAnimation = Duration(milliseconds: 1000);

  /// Extra short animation for micro-interactions
  static const Duration extraShortAnimation = Duration(milliseconds: 150);

  /// Loading animation duration
  static const Duration loadingAnimation = Duration(milliseconds: 800);

  // ==================== NETWORK TIMEOUTS ====================

  /// Standard network timeout for API calls
  static const Duration networkTimeout = Duration(seconds: 10);

  /// Long timeout for file uploads
  static const Duration uploadTimeout = Duration(seconds: 30);

  /// Short timeout for quick operations
  static const Duration shortTimeout = Duration(seconds: 5);

  // ==================== UI CONSTANTS ====================

  /// Default padding for most UI elements
  static const double defaultPadding = 16.0;

  /// Small padding for compact elements
  static const double smallPadding = 8.0;

  /// Large padding for spacious layouts
  static const double largePadding = 24.0;

  /// Extra large padding for major sections
  static const double extraLargePadding = 32.0;

  /// Default border radius for rounded corners
  static const double defaultBorderRadius = 12.0;

  /// Small border radius for subtle rounding
  static const double smallBorderRadius = 6.0;

  /// Large border radius for prominent elements
  static const double largeBorderRadius = 20.0;

  /// Card elevation for material design
  static const double cardElevation = 2.0;

  /// Modal elevation for overlays
  static const double modalElevation = 8.0;

  // ==================== SESSION CONSTANTS ====================

  /// Default maximum participants for a meal session
  static const int defaultMaxParticipants = 8;

  /// Minimum participants required for a session
  static const int minimumParticipants = 2;

  /// Maximum participants allowed
  static const int maximumParticipants = 20;

  /// Default session duration in hours
  static const int defaultSessionDurationHours = 2;

  /// Maximum days in advance to schedule a session
  static const int maxScheduleDaysAdvance = 30;

  // ==================== PAGINATION CONSTANTS ====================

  /// Default number of items per page
  static const int defaultPageSize = 20;

  /// Large page size for bulk operations
  static const int largePageSize = 50;

  /// Small page size for initial loads
  static const int smallPageSize = 10;

  // ==================== IMAGE CONSTANTS ====================

  /// Maximum image file size in bytes (5MB)
  static const int maxImageFileSize = 5 * 1024 * 1024;

  /// Default image quality for compression
  static const int defaultImageQuality = 85;

  /// Thumbnail image quality
  static const int thumbnailImageQuality = 70;

  /// Maximum image width for uploads
  static const int maxImageWidth = 1920;

  /// Maximum image height for uploads
  static const int maxImageHeight = 1080;

  /// Thumbnail size
  static const double thumbnailSize = 150.0;

  // ==================== SEARCH CONSTANTS ====================

  /// Minimum characters required for search
  static const int minSearchCharacters = 2;

  /// Debounce duration for search input
  static const Duration searchDebounce = Duration(milliseconds: 500);

  /// Maximum search results to display
  static const int maxSearchResults = 50;

  // ==================== CACHE CONSTANTS ====================

  /// Default cache duration for API responses
  static const Duration defaultCacheDuration = Duration(minutes: 5);

  /// Long cache duration for static data
  static const Duration longCacheDuration = Duration(hours: 1);

  /// Short cache duration for dynamic data
  static const Duration shortCacheDuration = Duration(minutes: 1);

  /// User profile cache duration
  static const Duration userProfileCacheDuration = Duration(minutes: 10);

  /// Restaurant data cache duration
  static const Duration restaurantCacheDuration = Duration(minutes: 30);

  // ==================== VALIDATION CONSTANTS ====================

  /// Minimum password length
  static const int minPasswordLength = 6;

  /// Maximum bio length
  static const int maxBioLength = 500;

  /// Maximum session title length
  static const int maxSessionTitleLength = 100;

  /// Maximum session description length
  static const int maxSessionDescriptionLength = 1000;

  /// Maximum username length
  static const int maxUsernameLength = 30;

  /// Minimum username length
  static const int minUsernameLength = 3;

  // ==================== MAP CONSTANTS ====================

  /// Default map zoom level
  static const double defaultMapZoom = 15.0;

  /// Minimum map zoom level
  static const double minMapZoom = 10.0;

  /// Maximum map zoom level
  static const double maxMapZoom = 18.0;

  /// Default search radius in kilometers
  static const double defaultSearchRadius = 5.0;

  /// Maximum search radius in kilometers
  static const double maxSearchRadius = 50.0;

  // ==================== NOTIFICATION CONSTANTS ====================

  /// Default snackbar duration
  static const Duration snackbarDuration = Duration(seconds: 3);

  /// Error snackbar duration
  static const Duration errorSnackbarDuration = Duration(seconds: 5);

  /// Success snackbar duration
  static const Duration successSnackbarDuration = Duration(seconds: 2);

  // ==================== AGE RANGE CONSTANTS ====================

  /// Minimum age for app usage
  static const int minimumAge = 16;

  /// Maximum age for app usage
  static const int maximumAge = 80;

  /// Default age range start
  static const int defaultAgeRangeStart = 18;

  /// Default age range end
  static const int defaultAgeRangeEnd = 35;

  // ==================== FEATURE FLAGS ====================

  /// Enable debug logging
  static const bool enableDebugLogging = true;

  /// Enable performance monitoring
  static const bool enablePerformanceMonitoring = true;

  /// Enable crash reporting
  static const bool enableCrashReporting = true;

  /// Enable analytics
  static const bool enableAnalytics = true;
}