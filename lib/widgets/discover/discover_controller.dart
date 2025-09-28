import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodbuddy/services/distance_service.dart';
import 'package:foodbuddy/services/location_service.dart';
import 'package:latlong2/latlong.dart';
import '../../data/dummy_data.dart';

class DiscoverController extends ChangeNotifier {
  // State variables
  bool _isCreateMode = false;
  bool _isLoading = true;
  bool _isMapInteracting = false;
  Map<String, dynamic>? _selectedRestaurant;
  List<Map<String, dynamic>> _availableSessions = [];
  List<Map<String, dynamic>> _userSessions = [];

  // Filter state
  List<String> _selectedCuisines = [];
  List<String> _selectedPriceRanges = [];

  // Animation controllers
  double _scrollOffset = 0.0;
  bool _isPanelExpanded = false;

  // Getters
  bool get isCreateMode => _isCreateMode;
  bool get isLoading => _isLoading;
  bool get isMapInteracting => _isMapInteracting;
  Map<String, dynamic>? get selectedRestaurant => _selectedRestaurant;
  List<Map<String, dynamic>> get availableSessions => _availableSessions;
  List<Map<String, dynamic>> get userSessions => _userSessions;
  List<String> get selectedCuisines => _selectedCuisines;
  List<String> get selectedPriceRanges => _selectedPriceRanges;
  double get scrollOffset => _scrollOffset;
  bool get isPanelExpanded => _isPanelExpanded;

  // Filter options
  final List<String> cuisineOptions = [
    'Italian', 'Korean', 'Vegan', 'Desserts', 'American', 'Mexican',
    'Chinese', 'Japanese', 'Thai', 'Mediterranean', 'French'
  ];

  final List<String> priceRangeOptions = ['₱', '₱₱', '₱₱₱', '₱₱₱₱'];

  // Initialize the controller
  Future<void> initialize() async {
    await loadDiscoverData();
  }

  // Load data from dummy data source
  Future<void> loadDiscoverData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    _availableSessions = DummyData.getOpenSessions()
        .where((session) => session['hostUserId'] != CurrentUser.userId)
        .toList();

    _userSessions = DummyData.getSessionsByUserId(CurrentUser.userId);

    _isLoading = false;
    notifyListeners();
  }

  // Mode management
  void toggleMode() {
    _isCreateMode = !_isCreateMode;
    _selectedRestaurant = null;
    _isPanelExpanded = false;
    notifyListeners();
  }

  void setCreateMode(bool isCreate) {
    if (_isCreateMode != isCreate) {
      _isCreateMode = isCreate;
      _selectedRestaurant = null;
      _isPanelExpanded = false;
      notifyListeners();
    }
  }

  // Restaurant selection
  void selectRestaurant(Map<String, dynamic>? restaurant) {
    _selectedRestaurant = restaurant;
    _isPanelExpanded = restaurant != null;
    notifyListeners();
  }

  // Map interaction state
  void setMapInteracting(bool isInteracting) {
    if (_isMapInteracting != isInteracting) {
      _isMapInteracting = isInteracting;
      notifyListeners();
    }
  }

  // Scroll offset for AppBar transitions
  void updateScrollOffset(double offset) {
    _scrollOffset = offset;
    notifyListeners();
  }

  // Panel state
  void setPanelExpanded(bool expanded) {
    if (_isPanelExpanded != expanded) {
      _isPanelExpanded = expanded;
      notifyListeners();
    }
  }

  // Filter management
  void updateFilters(List<String> cuisines, List<String> priceRanges) {
    _selectedCuisines = cuisines;
    _selectedPriceRanges = priceRanges;
    notifyListeners();
  }

  void toggleCuisineFilter(String cuisine) {
    if (_selectedCuisines.contains(cuisine)) {
      _selectedCuisines.remove(cuisine);
    } else {
      _selectedCuisines.add(cuisine);
    }
    notifyListeners();
  }

  void togglePriceRangeFilter(String priceRange) {
    if (_selectedPriceRanges.contains(priceRange)) {
      _selectedPriceRanges.remove(priceRange);
    } else {
      _selectedPriceRanges.add(priceRange);
    }
    notifyListeners();
  }

  void clearFilters() {
    _selectedCuisines.clear();
    _selectedPriceRanges.clear();
    notifyListeners();
  }

  // Get filtered restaurants
  List<Map<String, dynamic>> getFilteredRestaurants() {
    List<Map<String, dynamic>> restaurants = DummyData.restaurants;

    if (_selectedCuisines.isNotEmpty) {
      restaurants = restaurants.where((restaurant) =>
        _selectedCuisines.contains(restaurant['cuisine'])
      ).toList();
    }

    if (_selectedPriceRanges.isNotEmpty) {
      restaurants = restaurants.where((restaurant) =>
        _selectedPriceRanges.contains(restaurant['priceRange'])
      ).toList();
    }

    return restaurants;
  }

  // Get sessions for current mode
  List<Map<String, dynamic>> getCurrentSessions() {
    if (_isCreateMode) {
      return _userSessions;
    } else {
      return _availableSessions;
    }
  }

  // Get sessions for a specific restaurant
  List<Map<String, dynamic>> getSessionsForRestaurant(String restaurantId) {
    if (_isCreateMode) {
      return _userSessions.where((session) =>
        session['restaurantId'] == restaurantId
      ).toList();
    } else {
      return _availableSessions.where((session) =>
        session['restaurantId'] == restaurantId
      ).toList();
    }
  }

  // Session actions
  Future<void> joinSession(Map<String, dynamic> session) async {
    // Show loading feedback would be handled by UI
    await Future.delayed(const Duration(milliseconds: 1000));

    // Remove from available sessions (simulate joining)
    _availableSessions.removeWhere((s) => s['id'] == session['id']);
    notifyListeners();
  }

  Future<void> passSession(Map<String, dynamic> session) async {
    _availableSessions.removeWhere((s) => s['id'] == session['id']);
    notifyListeners();
  }

  Future<void> createSession(Map<String, dynamic> sessionData) async {
    // Show loading feedback would be handled by UI
    await Future.delayed(const Duration(milliseconds: 1500));

    // Add to user sessions
    _userSessions.insert(0, sessionData);

    // Clear selection
    _selectedRestaurant = null;
    _isPanelExpanded = false;

    notifyListeners();
  }

  // Map helpers
  bool hasAvailableSession(String restaurantId) {
    return _availableSessions.any((session) =>
      session['restaurantId'] == restaurantId
    );
  }

  bool hasUserSession(String restaurantId) {
    return _userSessions.any((session) =>
      session['restaurantId'] == restaurantId
    );
  }

  // Get pin color for restaurant
  Color getPinColor(String restaurantId) {
    if (_isCreateMode && hasUserSession(restaurantId)) {
      return Colors.blue; // User session color
    } else if (!_isCreateMode && hasAvailableSession(restaurantId)) {
      return Colors.green; // Available session color
    } else {
      return Colors.orange; // Default restaurant color
    }
  }

  // Map camera position helpers
  LatLng getRestaurantPosition(String restaurantId) {
    final restaurant = DummyData.getRestaurantById(restaurantId);
    if (restaurant != null) {
      return LatLng(
        restaurant['latitude']?.toDouble() ?? 0.0,
        restaurant['longitude']?.toDouble() ?? 0.0,
      );
    }
    return const LatLng(13.7659, 121.0581); // Default Alangilan, Batangas City position
  }

  // Analytics and metrics
  int get totalAvailableSessions => _availableSessions.length;
  int get totalUserSessions => _userSessions.length;
  int get activeFiltersCount => _selectedCuisines.length + _selectedPriceRanges.length;

  String get modeDisplayName => _isCreateMode ? 'Your Sessions' : 'Find Sessions';

  // Refresh data
  Future<void> refresh() async {
    await loadDiscoverData();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// State management for animations
class DiscoverAnimationController extends ChangeNotifier {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _mapController;

  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _mapScaleAnimation;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  Animation<double>? get fadeAnimation => _fadeAnimation;
  Animation<Offset>? get slideAnimation => _slideAnimation;
  Animation<double>? get mapScaleAnimation => _mapScaleAnimation;

  void initialize(TickerProvider vsync) {
    if (_isInitialized) return;

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    _mapController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _mapScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mapController,
      curve: Curves.easeOutBack,
    ));

    _isInitialized = true;
    notifyListeners();
  }

  void startEntryAnimation() {
    if (!_isInitialized) return;

    _fadeController.forward();
    _slideController.forward();
    _mapController.forward();
  }

  void resetAnimations() {
    if (!_isInitialized) return;

    _fadeController.reset();
    _slideController.reset();
    _mapController.reset();
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _fadeController.dispose();
      _slideController.dispose();
      _mapController.dispose();
    }
    super.dispose();
  }
}

Future<Map<String, dynamic>?> getDistanceInfo(String restaurantId) async {
  try {
    final currentLocation = await LocationService.getCurrentLocation();
    final restaurant = DummyData.getRestaurantById(restaurantId);
    
    if (restaurant != null && currentLocation != null) {
      final userLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);
      final restaurantLatLng = LatLng(
        restaurant['latitude']?.toDouble() ?? 0.0,
        restaurant['longitude']?.toDouble() ?? 0.0,
      );
      
      return await DistanceService.calculateDistanceAndTime(
        userLatLng,
        restaurantLatLng,
      );
    }
  } catch (e) {
    if (kDebugMode) debugPrint('Error getting distance info: $e');
  }
  return null;
}

// // Get nearby restaurants within a certain radius
// List<Map<String, dynamic>> getNearbyRestaurants(double radiusInKm) {
//   // This would need actual implementation with real coordinates
//   // For now, return all filtered restaurants
//   return getFilteredRestaurants();
// }