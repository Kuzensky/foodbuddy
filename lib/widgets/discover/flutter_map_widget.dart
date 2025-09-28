import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../data/dummy_data.dart';

enum MapLayerType {
  openStreetMap,
  satellite,
  terrain,
  dark,
  cartodb
}

class FlutterMapWidget extends StatefulWidget {
  final Function(Map<String, dynamic>)? onRestaurantSelected;
  final Function(Offset)? onMapTap;
  final List<String> filterCuisines;
  final List<String> filterPriceRanges;
  final bool showAvailableSessions;
  final bool showUserSessions;
  final bool showUserLocation;

  const FlutterMapWidget({
    super.key,
    this.onRestaurantSelected,
    this.onMapTap,
    this.filterCuisines = const [],
    this.filterPriceRanges = const [],
    this.showAvailableSessions = true,
    this.showUserSessions = false,
    this.showUserLocation = true,
  });

  @override
  State<FlutterMapWidget> createState() => _FlutterMapWidgetState();
}

class _FlutterMapWidgetState extends State<FlutterMapWidget> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  List<Map<String, dynamic>> _filteredRestaurants = [];
  Map<String, dynamic>? _selectedRestaurant;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isLoadingLocation = true;
  bool _isLoadingRestaurants = false;
  String? _locationError;
  bool _useRealRestaurants = true;
  bool _isMapReady = false;
  MapLayerType _currentMapLayer = MapLayerType.openStreetMap;

  // Alangilan, Batangas City, Batangas coordinates (more precise)
  static const LatLng _defaultLocation = LatLng(13.7659, 121.0581);

  LatLng get _initialPosition => LatLng(
    _currentPosition?.latitude ?? _defaultLocation.latitude,
    _currentPosition?.longitude ?? _defaultLocation.longitude,
  );

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
        _locationError = null;
      });

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Location services are disabled. Please enable them.';
          _isLoadingLocation = false;
          // Set a simulated position in Alangilan when location services disabled
          _currentPosition = Position(
            latitude: _defaultLocation.latitude,
            longitude: _defaultLocation.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        });
        _loadRestaurants();
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission if not granted
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Location permissions are denied. Please grant location access in app settings.';
            _isLoadingLocation = false;
            // Set a simulated position in Alangilan when permission denied
            _currentPosition = Position(
              latitude: _defaultLocation.latitude,
              longitude: _defaultLocation.longitude,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
          });
          _loadRestaurants();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permissions are permanently denied. Please enable them in app settings.';
          _isLoadingLocation = false;
          // Set a simulated position in Alangilan when permission denied forever
          _currentPosition = Position(
            latitude: _defaultLocation.latitude,
            longitude: _defaultLocation.longitude,
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            heading: 0,
            speed: 0,
            speedAccuracy: 0,
            altitudeAccuracy: 0,
            headingAccuracy: 0,
          );
        });
        _loadRestaurants();
        return;
      }

      // If we get here, permissions are granted

      // Get current position with timeout and better error handling
      try {
        // FOR TESTING: Always use Alangilan location instead of actual GPS
        // Uncomment the next line to use real GPS:
        // _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best,).timeout(const Duration(seconds: 15));

        // Force Alangilan location for testing (remove this to use real GPS)
        _currentPosition = Position(
          latitude: _defaultLocation.latitude,
          longitude: _defaultLocation.longitude,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('Error getting current position: $e');
        // Continue with default location if current position fails
        _currentPosition = null;
      }

      // Start listening to location updates if enabled
      // DISABLED FOR TESTING: Prevents GPS from updating location to real coordinates
      // Uncomment this section to enable real GPS tracking:
      /*
      if (widget.showUserLocation && permission == LocationPermission.whileInUse) {
        _positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 10, // Update every 10 meters
          ),
        ).listen((position) {
          if (mounted) {
            setState(() {
              _currentPosition = position;
            });
            _updateUserLocationMarker();
          }
        });
      }
      */

      setState(() {
        _isLoadingLocation = false;
      });

      // Load restaurants
      _loadRestaurants();

    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing location: $e');
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Unable to access location: ${e.toString()}';
        // Set a simulated position in Alangilan if GPS fails
        _currentPosition = Position(
          latitude: _defaultLocation.latitude,
          longitude: _defaultLocation.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      });
      _loadRestaurants(); // Still load restaurants even if location fails
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Permission granted, reinitialize location
        await _initializeLocation();
      } else {
        setState(() {
          _locationError = 'Location permission is required to show your current location.';
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error requesting permission: $e');
      setState(() {
        _locationError = 'Error requesting location permission.';
      });
    }
  }

  Future<void> _openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      if (kDebugMode) debugPrint('Error opening app settings: $e');
    }
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoadingRestaurants = true;
    });

    try {
      // For now, we'll use dummy data since Places Service might need Google Maps API
      _loadDummyRestaurants();
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading restaurants: $e');
      _loadDummyRestaurants();
    } finally {
      setState(() {
        _isLoadingRestaurants = false;
      });
    }
  }

  void _loadDummyRestaurants() {
    List<Map<String, dynamic>> restaurants = DummyData.restaurants;

    if (widget.filterCuisines.isNotEmpty) {
      restaurants = restaurants.where((restaurant) {
        final cuisine = restaurant['cuisine']?.toString().toLowerCase() ?? '';
        return widget.filterCuisines.any((filter) =>
          cuisine.contains(filter.toLowerCase()));
      }).toList();
    }

    if (widget.filterPriceRanges.isNotEmpty) {
      restaurants = restaurants.where((restaurant) {
        final priceRange = restaurant['priceRange']?.toString() ?? '';
        return widget.filterPriceRanges.contains(priceRange);
      }).toList();
    }

    setState(() {
      _filteredRestaurants = restaurants;
      _useRealRestaurants = false;
    });

    _createMarkers();
  }

  void _createMarkers() async {
    List<Marker> markers = [];

    // Add user location marker if available and enabled
    if (widget.showUserLocation && _currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    // Add restaurant markers
    for (int i = 0; i < _filteredRestaurants.length; i++) {
      final restaurant = _filteredRestaurants[i];

      double lat, lng;
      if (restaurant['latitude'] != null && restaurant['longitude'] != null) {
        lat = restaurant['latitude'].toDouble();
        lng = restaurant['longitude'].toDouble();
      } else {
        final baseLat = _currentPosition?.latitude ?? _defaultLocation.latitude;
        final baseLng = _currentPosition?.longitude ?? _defaultLocation.longitude;
        lat = baseLat + (i % 10 - 5) * 0.005;
        lng = baseLng + (i % 10 - 5) * 0.005;
      }

      final isSelected = _selectedRestaurant?['id'] == restaurant['id'];

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: 40,
          height: 60,
          child: GestureDetector(
            onTap: () => _onRestaurantTapped(restaurant),
            child: Column(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : _getMarkerColor(restaurant),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getMarkerIcon(restaurant),
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      restaurant['name'] ?? 'Restaurant',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });

    if (_filteredRestaurants.isNotEmpty && _currentPosition != null) {
      _fitMarkersInView();
    }
  }

  void _fitMarkersInView() {
    if (!_isMapReady || _markers.length <= 1) return;

    try {
      double minLat = _currentPosition!.latitude;
      double maxLat = _currentPosition!.latitude;
      double minLng = _currentPosition!.longitude;
      double maxLng = _currentPosition!.longitude;

      for (Marker marker in _markers) {
        final lat = marker.point.latitude;
        final lng = marker.point.longitude;

        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
        if (lng < minLng) minLng = lng;
        if (lng > maxLng) maxLng = lng;
      }

      final bounds = LatLngBounds(
        LatLng(minLat, minLng),
        LatLng(maxLat, maxLng),
      );

      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error fitting markers: $e');
      // Don't try to center on user location if map isn't ready
    }
  }

  Color _getMarkerColor(Map<String, dynamic> restaurant) {
    final priceRange = restaurant['priceRange']?.toString() ?? '';
    switch (priceRange) {
      case '₱':
        return Colors.green;
      case '₱₱':
        return Colors.yellow[700]!;
      case '₱₱₱':
        return Colors.orange;
      case '₱₱₱₱':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  IconData _getMarkerIcon(Map<String, dynamic> restaurant) {
    if (widget.showAvailableSessions) {
      return Icons.restaurant;
    }
    if (widget.showUserSessions) {
      return Icons.person;
    }
    return Icons.place;
  }

  void _updateUserLocationMarker() {
    if (widget.showUserLocation && _currentPosition != null) {
      _createMarkers();
    }
  }

  void _onRestaurantTapped(Map<String, dynamic> restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
    });

    if (_isMapReady) {
      double lat, lng;
      if (restaurant['latitude'] != null && restaurant['longitude'] != null) {
        lat = restaurant['latitude'].toDouble();
        lng = restaurant['longitude'].toDouble();
      } else {
        lat = _defaultLocation.latitude;
        lng = _defaultLocation.longitude;
      }

      try {
        _mapController.move(LatLng(lat, lng), 16.0);
      } catch (e) {
        if (kDebugMode) debugPrint('Error moving to restaurant: $e');
      }
    }

    widget.onRestaurantSelected?.call(restaurant);
    _createMarkers();
  }

  void _centerOnUserLocation({bool animate = true}) {
    if (!_isMapReady || _currentPosition == null) return;

    try {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error centering on user location: $e');
    }
  }

  void _toggleRestaurantSource() {
    setState(() {
      _useRealRestaurants = !_useRealRestaurants;
    });
    _loadRestaurants();
  }

  TileLayer _getTileLayer() {
    switch (_currentMapLayer) {
      case MapLayerType.openStreetMap:
        return TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.foodbuddy',
          maxNativeZoom: 19,
        );
      case MapLayerType.satellite:
        return TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.example.foodbuddy',
          maxNativeZoom: 19,
        );
      case MapLayerType.terrain:
        return TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Terrain_Base/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.example.foodbuddy',
          maxNativeZoom: 13,
        );
      case MapLayerType.dark:
        return TileLayer(
          urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.foodbuddy',
          maxNativeZoom: 19,
        );
      case MapLayerType.cartodb:
        return TileLayer(
          urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.example.foodbuddy',
          maxNativeZoom: 19,
        );
    }
  }

  void _changeMapLayer(MapLayerType newLayer) {
    setState(() {
      _currentMapLayer = newLayer;
    });
  }

  String _getMapLayerName(MapLayerType layer) {
    switch (layer) {
      case MapLayerType.openStreetMap:
        return 'Street';
      case MapLayerType.satellite:
        return 'Satellite';
      case MapLayerType.terrain:
        return 'Terrain';
      case MapLayerType.dark:
        return 'Dark';
      case MapLayerType.cartodb:
        return 'Light';
    }
  }

  IconData _getMapLayerIcon(MapLayerType layer) {
    switch (layer) {
      case MapLayerType.openStreetMap:
        return Icons.map;
      case MapLayerType.satellite:
        return Icons.satellite_alt;
      case MapLayerType.terrain:
        return Icons.terrain;
      case MapLayerType.dark:
        return Icons.dark_mode;
      case MapLayerType.cartodb:
        return Icons.light_mode;
    }
  }

  void _showMapLayerSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.layers, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Map Style',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: MapLayerType.values.length,
                itemBuilder: (context, index) {
                  final layer = MapLayerType.values[index];
                  final isSelected = layer == _currentMapLayer;

                  return ListTile(
                    leading: Icon(
                      _getMapLayerIcon(layer),
                      color: isSelected ? Colors.blue : Colors.grey[600],
                    ),
                    title: Text(
                      _getMapLayerName(layer),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                    onTap: () {
                      _changeMapLayer(layer);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Location Access Needed',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _locationError ?? 'Location permission is required to show your current location and nearby restaurants.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _requestLocationPermission,
            child: const Text('Grant Permission'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _openAppSettings,
            child: const Text('Open App Settings'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _toggleRestaurantSource,
            child: Text(
              'Continue with Sample Restaurants',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Getting your location...'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return _buildLoadingWidget();
    }

    if (_locationError != null && _currentPosition == null) {
      return _buildErrorWidget();
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _initialPosition,
            initialZoom: 15.0,
            onMapReady: () {
              setState(() {
                _isMapReady = true;
              });
              // Now that map is ready, try to fit markers if we have them
              if (_filteredRestaurants.isNotEmpty && _currentPosition != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _fitMarkersInView();
                });
              }
            },
            onTap: (tapPosition, point) {
              setState(() {
                _selectedRestaurant = null;
              });
              widget.onMapTap?.call(Offset(point.latitude, point.longitude));
              _createMarkers();
            },
          ),
          children: [
            _getTileLayer(),
            MarkerLayer(
              markers: _markers,
            ),
          ],
        ),

        if (widget.showUserLocation)
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            children: [
              // Map Layer Selector
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'map_layer',
                  onPressed: _showMapLayerSelector,
                  child: const Icon(Icons.layers, size: 20),
                ),
              ),
              if (!kReleaseMode) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: 'data_toggle',
                    onPressed: _toggleRestaurantSource,
                    child: Icon(
                      _useRealRestaurants ? Icons.data_array : Icons.fastfood,
                      size: 20,
                    ),
                  ),
                ),
              ],
              FloatingActionButton(
                mini: true,
                heroTag: 'location',
                onPressed: _centerOnUserLocation,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),

        if (_isLoadingRestaurants)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Loading restaurants...',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Map style indicator
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getMapLayerIcon(_currentMapLayer),
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _getMapLayerName(_currentMapLayer),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        if (!kReleaseMode)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: _useRealRestaurants ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _useRealRestaurants ? 'Real Restaurants' : 'Sample Data',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void didUpdateWidget(FlutterMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterCuisines != widget.filterCuisines ||
        oldWidget.filterPriceRanges != widget.filterPriceRanges ||
        oldWidget.showAvailableSessions != widget.showAvailableSessions ||
        oldWidget.showUserSessions != widget.showUserSessions ||
        oldWidget.showUserLocation != widget.showUserLocation) {
      _loadRestaurants();
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }
}