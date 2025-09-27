// widgets/google_map_widget.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../services/location_service.dart';
import '../../services/distance_service.dart';
import '../../services/places_service.dart';
import '../../data/dummy_data.dart';
import '../../config/maps_config.dart';

class GoogleMapWidget extends StatefulWidget {
  final Function(Map<String, dynamic>)? onRestaurantSelected;
  final Function(Offset)? onMapTap;
  final List<String> filterCuisines;
  final List<String> filterPriceRanges;
  final bool showAvailableSessions;
  final bool showUserSessions;
  final bool showUserLocation;

  const GoogleMapWidget({
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
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _filteredRestaurants = [];
  Map<String, dynamic>? _selectedRestaurant;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _isLoadingLocation = true;
  bool _isLoadingRestaurants = false;
  String? _locationError;
  bool _useRealRestaurants = true;
  bool _permissionRequested = false;

  CameraPosition get _initialPosition => CameraPosition(
    target: LatLng(
      _currentPosition?.latitude ?? 14.5995,
      _currentPosition?.longitude ?? 120.9842,
    ),
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _checkApiKey();
    _initializeLocation();
  }

  void _checkApiKey() {
    if (!MapsConfig.hasApiKey) {
      print('Warning: Google Maps API key not configured. '
          'Please update MapsConfig.mapsApiKey with your actual API key.');
    }
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
        });
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
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Location permissions are permanently denied. Please enable them in app settings.';
          _isLoadingLocation = false;
        });
        return;
      }

      // If we get here, permissions are granted
      _permissionRequested = true;

      // Get current position with timeout and better error handling
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        ).timeout(const Duration(seconds: 15));
      } catch (e) {
        print('Error getting current position: $e');
        // Continue with default location if current position fails
        _currentPosition = null;
      }

      // Start listening to location updates if enabled
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

      setState(() {
        _isLoadingLocation = false;
      });
      
      // Load restaurants
      _loadRestaurants();
      
    } catch (e) {
      print('Error initializing location: $e');
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Unable to access location: ${e.toString()}';
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
      print('Error requesting permission: $e');
      setState(() {
        _locationError = 'Error requesting location permission.';
      });
    }
  }

  Future<void> _openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  Future<void> _loadRestaurants() async {
    if (_currentPosition == null && _useRealRestaurants) {
      _loadDummyRestaurants();
      return;
    }

    setState(() {
      _isLoadingRestaurants = true;
    });

    try {
      if (_useRealRestaurants && MapsConfig.hasApiKey && _currentPosition != null) {
        await _loadNearbyRestaurants();
      } else {
        _loadDummyRestaurants();
      }
    } catch (e) {
      print('Error loading restaurants: $e');
      _loadDummyRestaurants();
    } finally {
      setState(() {
        _isLoadingRestaurants = false;
      });
    }
  }

  Future<void> _loadNearbyRestaurants() async {
    try {
      final nearbyRestaurants = await PlacesService.getNearbyRestaurants(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        radius: 2000,
      );

      if (nearbyRestaurants.isNotEmpty) {
        List<Map<String, dynamic>> filtered = nearbyRestaurants;
        
        if (widget.filterCuisines.isNotEmpty) {
          filtered = filtered.where((restaurant) {
            final cuisine = restaurant['cuisine']?.toString().toLowerCase() ?? '';
            return widget.filterCuisines.any((filter) =>
              cuisine.contains(filter.toLowerCase()));
          }).toList();
        }

        if (widget.filterPriceRanges.isNotEmpty) {
          filtered = filtered.where((restaurant) {
            final priceRange = restaurant['priceRange']?.toString() ?? '';
            return widget.filterPriceRanges.contains(priceRange);
          }).toList();
        }

        setState(() {
          _filteredRestaurants = filtered;
        });
        
        _createMarkers();
      } else {
        _loadDummyRestaurants();
      }
    } catch (e) {
      print('Error loading nearby restaurants: $e');
      _loadDummyRestaurants();
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
    Set<Marker> markers = {};

    // Add user location marker if available and enabled
    if (widget.showUserLocation && _currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
          zIndex: 3,
          flat: true,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    // Add restaurant markers
    for (int i = 0; i < _filteredRestaurants.length; i++) {
      final restaurant = _filteredRestaurants[i];
      final restaurantId = restaurant['id'] ?? 'restaurant_$i';

      double lat, lng;
      if (restaurant['latitude'] != null && restaurant['longitude'] != null) {
        lat = restaurant['latitude'].toDouble();
        lng = restaurant['longitude'].toDouble();
      } else {
        final baseLat = _currentPosition?.latitude ?? 14.5995;
        final baseLng = _currentPosition?.longitude ?? 120.9842;
        lat = baseLat + (i % 10 - 5) * 0.005;
        lng = baseLng + (i % 10 - 5) * 0.005;
      }

      String distanceInfo = '';
      if (_currentPosition != null) {
        final restaurantLatLng = LatLng(lat, lng);
        final userLatLng = LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        
        final distance = DistanceService.calculateStraightLineDistance(
          userLatLng,
          restaurantLatLng,
        );
        
        distanceInfo = '${(distance / 1000).toStringAsFixed(1)} km away';
        _getDetailedDistanceInfo(userLatLng, restaurantLatLng, restaurantId);
      }

      markers.add(
        Marker(
          markerId: MarkerId(restaurantId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: restaurant['name'] ?? 'Restaurant',
            snippet: _buildInfoSnippet(restaurant, distanceInfo),
          ),
          onTap: () => _onRestaurantTapped(restaurant),
          icon: await _getCustomMarkerIcon(restaurant),
          zIndex: 2,
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
    if (_mapController == null || _markers.length <= 1) return;

    try {
      LatLngBounds bounds = _calculateBounds();
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100),
      );
    } catch (e) {
      print('Error fitting markers: $e');
      _centerOnUserLocation();
    }
  }

  LatLngBounds _calculateBounds() {
    double minLat = _currentPosition!.latitude;
    double maxLat = _currentPosition!.latitude;
    double minLng = _currentPosition!.longitude;
    double maxLng = _currentPosition!.longitude;

    for (Marker marker in _markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;
      
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  String _buildInfoSnippet(Map<String, dynamic> restaurant, String distanceInfo) {
    final cuisine = restaurant['cuisine'] ?? '';
    final priceRange = restaurant['priceRange'] ?? '';
    final rating = restaurant['rating']?.toString() ?? '';
    final address = restaurant['address'] ?? '';
    
    String snippet = '';
    if (cuisine.isNotEmpty) snippet += '$cuisine • ';
    snippet += priceRange.isNotEmpty ? priceRange : 'Price not available';
    
    if (rating.isNotEmpty) {
      snippet += ' • ⭐$rating';
    }
    
    if (address.isNotEmpty && address.length < 30) {
      snippet += '\n$address';
    }
    
    if (distanceInfo.isNotEmpty) {
      snippet += '\n$distanceInfo';
    }
    
    return snippet;
  }

  Future<BitmapDescriptor> _getCustomMarkerIcon(Map<String, dynamic> restaurant) async {
    if (_selectedRestaurant?['id'] == restaurant['id']) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
    
    final priceRange = restaurant['priceRange']?.toString() ?? '';
    switch (priceRange) {
      case '₱':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case '₱₱':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case '₱₱₱':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case '₱₱₱₱':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    }
  }

  Future<void> _getDetailedDistanceInfo(
    LatLng userLocation,
    LatLng restaurantLocation,
    String restaurantId,
  ) async {
    final details = await DistanceService.calculateDistanceAndTime(
      userLocation,
      restaurantLocation,
    );
    
    if (details != null && mounted) {
      final updatedMarkers = _markers.map((marker) {
        if (marker.markerId.value == restaurantId) {
          final restaurant = _filteredRestaurants.firstWhere(
            (r) => r['id'] == restaurantId,
            orElse: () => {},
          );
          
          String snippet = _buildInfoSnippet(restaurant, '');
          if (details['isEstimate'] == true) {
            snippet += '\n🚶 ${details['duration']} (est.)';
          } else {
            snippet += '\n🚗 ${details['duration']} • ${details['distance']}';
          }
          
          return marker.copyWith(
            infoWindowParam: InfoWindow(
              title: marker.infoWindow.title,
              snippet: snippet,
            ),
          );
        }
        return marker;
      }).toSet();

      setState(() {
        _markers = updatedMarkers;
      });
    }
  }

  void _updateUserLocationMarker() {
    if (widget.showUserLocation && _currentPosition != null) {
      final userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your Location'),
        zIndex: 3,
        flat: true,
        anchor: const Offset(0.5, 0.5),
      );

      setState(() {
        _markers.removeWhere((marker) => marker.markerId.value == 'user_location');
        _markers.add(userMarker);
      });
    }
  }

  void _onRestaurantTapped(Map<String, dynamic> restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
    });
    
    double lat, lng;
    if (restaurant['latitude'] != null && restaurant['longitude'] != null) {
      lat = restaurant['latitude'].toDouble();
      lng = restaurant['longitude'].toDouble();
    } else {
      lat = 14.5995;
      lng = 120.9842;
    }
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16.0),
    );
    
    widget.onRestaurantSelected?.call(restaurant);
    _createMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    if (_currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _centerOnUserLocation(animate: true);
      });
    }
  }

  void _centerOnUserLocation({bool animate = true}) {
    if (_currentPosition != null && _mapController != null) {
      final cameraUpdate = CameraUpdate.newLatLngZoom(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
      
      if (animate) {
        _mapController?.animateCamera(cameraUpdate);
      } else {
        _mapController?.moveCamera(cameraUpdate);
      }
    }
  }

  void _toggleRestaurantSource() {
    setState(() {
      _useRealRestaurants = !_useRealRestaurants;
    });
    _loadRestaurants();
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Getting your location...'),
          if (_isLoadingRestaurants) ...[
            SizedBox(height: 8),
            Text('Loading nearby restaurants...', 
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
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
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _initialPosition,
          markers: _markers,
          onTap: (LatLng position) {
            setState(() {
              _selectedRestaurant = null;
            });
            widget.onMapTap?.call(Offset(position.latitude, position.longitude));
            _createMarkers();
          },
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: widget.showUserLocation && _currentPosition != null,
          mapType: MapType.normal,
          compassEnabled: true,
        ),
        
        if (widget.showUserLocation)
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            children: [
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
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

        if (!MapsConfig.hasApiKey && !kReleaseMode)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.orange,
              child: Text(
                'API Key Required: Update MapsConfig.mapsApiKey',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),

        if (!kReleaseMode)
          Positioned(
            top: 40,
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
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
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
    _mapController?.dispose();
    super.dispose();
  }
}