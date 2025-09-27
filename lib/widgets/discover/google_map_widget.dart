// widgets/google_map_widget.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../services/location_service.dart';
import '../../services/distance_service.dart';
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
  String? _locationError;

  CameraPosition get _initialPosition => CameraPosition(
    target: LatLng(
      _currentPosition?.latitude ?? 14.5995, // Default to Manila coordinates
      _currentPosition?.longitude ?? 120.9842,
    ),
    zoom: 14.0,
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
      // Get initial position
      _currentPosition = await LocationService.getCurrentLocation();
      
      // Start listening to location updates if enabled
      if (widget.showUserLocation) {
        _positionStream = LocationService.getLocationStream().listen((position) {
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
      
      _loadRestaurants();
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Unable to access location: $e';
      });
      _loadRestaurants(); // Still load restaurants even if location fails
    }
  }

  void _loadRestaurants() {
    List<Map<String, dynamic>> restaurants = DummyData.restaurants;

    // Filter restaurants based on criteria
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
          zIndex: 2,
        ),
      );
    }

    // Add restaurant markers
    for (int i = 0; i < _filteredRestaurants.length; i++) {
      final restaurant = _filteredRestaurants[i];
      final restaurantId = restaurant['id'] ?? 'restaurant_$i';

      // Get coordinates (use realistic Manila area coordinates)
      final lat = 14.5995 + (i % 10 - 5) * 0.01; // Spread around Manila
      final lng = 120.9842 + (i % 10 - 5) * 0.01;

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
        
        // Get detailed distance info asynchronously
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
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  String _buildInfoSnippet(Map<String, dynamic> restaurant, String distanceInfo) {
    final cuisine = restaurant['cuisine'] ?? '';
    final priceRange = restaurant['priceRange'] ?? '';
    final rating = restaurant['rating']?.toString() ?? '';
    
    String snippet = '$cuisine • $priceRange';
    if (rating.isNotEmpty) {
      snippet += ' • ⭐$rating';
    }
    if (distanceInfo.isNotEmpty) {
      snippet += '\n$distanceInfo';
    }
    
    return snippet;
  }

  Future<BitmapDescriptor> _getCustomMarkerIcon(Map<String, dynamic> restaurant) async {
    // Selected restaurant gets blue marker
    if (_selectedRestaurant?['id'] == restaurant['id']) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
    
    // Color code by price range
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
        return BitmapDescriptor.defaultMarker;
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
      // Update the marker with detailed info
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
    if (widget.showUserLocation && _currentPosition != null && _markers.isNotEmpty) {
      final updatedMarkers = _markers.where((marker) => 
        marker.markerId.value != 'user_location'
      ).toSet();
      
      updatedMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
          zIndex: 2,
        ),
      );

      setState(() {
        _markers = updatedMarkers;
      });
    }
  }

  void _onRestaurantTapped(Map<String, dynamic> restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
    });
    
    // Animate to the selected restaurant
    final lat = restaurant['latitude']?.toDouble() ?? 14.5995;
    final lng = restaurant['longitude']?.toDouble() ?? 120.9842;
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16.0),
    );
    
    widget.onRestaurantSelected?.call(restaurant);
    _createMarkers(); // Refresh markers to update selected state
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _centerOnUserLocation() {
    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          14.0,
        ),
      );
    } else if (_locationError != null) {
      // Show error snackbar if location is not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_locationError!)),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Location Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _locationError ?? 'Unknown location error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeLocation,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
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
          myLocationButtonEnabled: false, // We use custom button
          myLocationEnabled: widget.showUserLocation,
          mapType: MapType.normal,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
        ),
        
        // Custom location button
        if (widget.showUserLocation)
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            onPressed: _centerOnUserLocation,
            child: const Icon(Icons.my_location),
          ),
        ),

        // API key warning banner (only shown in debug mode)
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