import 'package:flutter/foundation.dart';
import '../services/database_service.dart';
import '../utils/logger.dart';
import '../constants/app_constants.dart';

/// Provider responsible for restaurant data management
class RestaurantProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  // Restaurant data
  List<Map<String, dynamic>> _restaurants = [];
  bool _isRestaurantsLoading = false;
  String? _error;
  DateTime? _lastLoadTime;

  // Getters
  List<Map<String, dynamic>> get restaurants => List.unmodifiable(_restaurants);
  bool get isRestaurantsLoading => _isRestaurantsLoading;
  String? get error => _error;

  /// Check if restaurants data needs refresh
  bool get needsRefresh {
    if (_lastLoadTime == null) return true;
    return DateTime.now().difference(_lastLoadTime!) > AppConstants.restaurantCacheDuration;
  }

  /// Load restaurants with intelligent caching
  Future<void> loadRestaurants({bool forceRefresh = false}) async {
    // Skip loading if data is fresh and not forcing refresh
    if (!forceRefresh && !needsRefresh && _restaurants.isNotEmpty) {
      logDebug('Using cached restaurant data');
      return;
    }

    try {
      _isRestaurantsLoading = true;
      _error = null;
      notifyListeners();

      logDatabase('Loading restaurants${forceRefresh ? ' (forced refresh)' : ''}');

      _restaurants = await _db.getRestaurants();
      _lastLoadTime = DateTime.now();

      logSuccess('Loaded ${_restaurants.length} restaurants');

      _isRestaurantsLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Failed to load restaurants';
      _isRestaurantsLoading = false;
      logError('Error loading restaurants', e, stackTrace);
      notifyListeners();
    }
  }

  /// Get restaurant by ID
  Future<Map<String, dynamic>?> getRestaurant(String restaurantId) async {
    try {
      logDatabase('Getting restaurant: $restaurantId');

      // Check cache first
      final cachedRestaurant = _restaurants.firstWhere(
        (restaurant) => restaurant['id'] == restaurantId,
        orElse: () => {},
      );

      if (cachedRestaurant.isNotEmpty) {
        logDebug('Returning cached restaurant data');
        return cachedRestaurant;
      }

      // Fetch from database
      final restaurant = await _db.getRestaurant(restaurantId);

      if (restaurant != null) {
        logSuccess('Restaurant loaded from database');
        // Add to cache
        _restaurants.removeWhere((r) => r['id'] == restaurantId);
        _restaurants.add(restaurant);
        notifyListeners();
      }

      return restaurant;
    } catch (e, stackTrace) {
      logError('Error getting restaurant', e, stackTrace);
      return null;
    }
  }

  /// Search restaurants by query
  Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
    try {
      logDatabase('Searching restaurants with query: $query');

      final results = await _db.searchRestaurants(query);

      logSuccess('Found ${results.length} restaurants matching query');

      return results;
    } catch (e, stackTrace) {
      logError('Error searching restaurants', e, stackTrace);
      return [];
    }
  }

  /// Filter restaurants by criteria
  List<Map<String, dynamic>> filterRestaurants({
    List<String>? cuisines,
    List<String>? priceRanges,
    double? maxDistance,
    double? minRating,
  }) {
    logDebug('Filtering restaurants with criteria');

    var filtered = _restaurants;

    if (cuisines != null && cuisines.isNotEmpty) {
      filtered = filtered.where((restaurant) {
        final cuisine = restaurant['cuisine']?.toString().toLowerCase();
        return cuisines.any((c) => cuisine?.contains(c.toLowerCase()) == true);
      }).toList();
    }

    if (priceRanges != null && priceRanges.isNotEmpty) {
      filtered = filtered.where((restaurant) {
        final priceRange = restaurant['priceRange']?.toString();
        return priceRanges.contains(priceRange);
      }).toList();
    }

    if (minRating != null) {
      filtered = filtered.where((restaurant) {
        final rating = restaurant['rating'] as double? ?? 0.0;
        return rating >= minRating;
      }).toList();
    }

    logDebug('Filtered to ${filtered.length} restaurants');

    return filtered;
  }

  /// Get restaurants by location (within radius)
  Future<List<Map<String, dynamic>>> getRestaurantsByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      logDatabase('Getting restaurants by location (lat: $latitude, lng: $longitude, radius: ${radiusKm}km)');

      // Ensure restaurants are loaded
      await loadRestaurants();

      // Filter by distance (simplified - in production use proper geospatial queries)
      final nearby = _restaurants.where((restaurant) {
        final lat = restaurant['latitude'] as double?;
        final lng = restaurant['longitude'] as double?;

        if (lat == null || lng == null) return false;

        // Simple distance calculation (for demo purposes)
        final distance = _calculateDistance(latitude, longitude, lat, lng);
        return distance <= radiusKm;
      }).toList();

      logSuccess('Found ${nearby.length} restaurants within ${radiusKm}km');

      return nearby;
    } catch (e, stackTrace) {
      logError('Error getting restaurants by location', e, stackTrace);
      return [];
    }
  }

  /// Get unique cuisines from restaurants
  List<String> getAvailableCuisines() {
    final cuisines = <String>{};

    for (final restaurant in _restaurants) {
      final cuisine = restaurant['cuisine']?.toString();
      if (cuisine != null && cuisine.isNotEmpty) {
        cuisines.add(cuisine);
      }
    }

    return cuisines.toList()..sort();
  }

  /// Get unique price ranges from restaurants
  List<String> getAvailablePriceRanges() {
    final priceRanges = <String>{};

    for (final restaurant in _restaurants) {
      final priceRange = restaurant['priceRange']?.toString();
      if (priceRange != null && priceRange.isNotEmpty) {
        priceRanges.add(priceRange);
      }
    }

    return priceRanges.toList()..sort();
  }

  /// Calculate distance between two points (simplified)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // Simplified distance calculation for demo
    // In production, use proper geospatial calculations
    const double earthRadius = 6371; // km

    final dLat = (lat2 - lat1) * (3.14159 / 180);
    final dLng = (lng2 - lng1) * (3.14159 / 180);

    final a = (dLat / 2).abs() + (dLng / 2).abs();
    return a * earthRadius;
  }

  /// Refresh restaurant data
  Future<void> refresh() async {
    logInfo('Refreshing restaurant data');
    await loadRestaurants(forceRefresh: true);
  }

  /// Clear restaurant data
  void clearRestaurantData() {
    logInfo('Clearing restaurant data');

    _restaurants.clear();
    _isRestaurantsLoading = false;
    _error = null;
    _lastLoadTime = null;

    notifyListeners();
  }
}

/// Extension to add logging functionality
extension RestaurantProviderLogging on RestaurantProvider {
  void logDebug(String message) => AppLogger.debug(message, 'RestaurantProvider');
  void logInfo(String message) => AppLogger.info(message, 'RestaurantProvider');
  void logWarning(String message) => AppLogger.warning(message, 'RestaurantProvider');
  void logError(String message, [Object? error, StackTrace? stackTrace]) =>
      AppLogger.error(message, error, stackTrace, 'RestaurantProvider');
  void logSuccess(String message) => AppLogger.success(message, 'RestaurantProvider');
  void logDatabase(String message) => AppLogger.database(message, 'RestaurantProvider');
}