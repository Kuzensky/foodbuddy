import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../data/dummy_data.dart';

class GoogleMapWidget extends StatefulWidget {
  final Function(Map<String, dynamic>)? onRestaurantSelected;
  final Function(Offset)? onMapTap;
  final List<String> filterCuisines;
  final List<String> filterPriceRanges;
  final bool showAvailableSessions;
  final bool showUserSessions;

  const GoogleMapWidget({
    super.key,
    this.onRestaurantSelected,
    this.onMapTap,
    this.filterCuisines = const [],
    this.filterPriceRanges = const [],
    this.showAvailableSessions = true,
    this.showUserSessions = false,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _filteredRestaurants = [];
  Map<String, dynamic>? _selectedRestaurant;

  // Default location - you can adjust this to your preferred starting location
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // San Francisco coordinates
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void didUpdateWidget(GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterCuisines != widget.filterCuisines ||
        oldWidget.filterPriceRanges != widget.filterPriceRanges ||
        oldWidget.showAvailableSessions != widget.showAvailableSessions ||
        oldWidget.showUserSessions != widget.showUserSessions) {
      _loadRestaurants();
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
      _createMarkers();
    });
  }

  void _createMarkers() {
    Set<Marker> markers = {};

    for (int i = 0; i < _filteredRestaurants.length; i++) {
      final restaurant = _filteredRestaurants[i];
      final restaurantId = restaurant['id'] ?? 'restaurant_$i';

      // Generate coordinates around the initial position
      // In a real app, you'd have actual lat/lng for each restaurant
      final lat = 37.7749 + (i * 0.01) - 0.05;
      final lng = -122.4194 + (i * 0.01) - 0.05;

      markers.add(
        Marker(
          markerId: MarkerId(restaurantId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: restaurant['name'] ?? 'Restaurant',
            snippet: '${restaurant['cuisine']} • ${restaurant['priceRange']}',
          ),
          onTap: () => _onRestaurantTapped(restaurant),
          icon: _selectedRestaurant?['id'] == restaurantId
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  void _onRestaurantTapped(Map<String, dynamic> restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
      _createMarkers(); // Refresh markers to update selected state
    });
    widget.onRestaurantSelected?.call(restaurant);
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedRestaurant = null;
      _createMarkers(); // Refresh markers to update selected state
    });
    widget.onMapTap?.call(Offset(position.latitude, position.longitude));
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialPosition,
        markers: _markers,
        onTap: _onMapTapped,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        mapType: MapType.normal,
        style: '''
        [
          {
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#f5f5f5"
              }
            ]
          },
          {
            "elementType": "labels.icon",
            "stylers": [
              {
                "visibility": "off"
              }
            ]
          },
          {
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#616161"
              }
            ]
          },
          {
            "elementType": "labels.text.stroke",
            "stylers": [
              {
                "color": "#f5f5f5"
              }
            ]
          }
        ]
        ''',
      ),
    );
  }
}