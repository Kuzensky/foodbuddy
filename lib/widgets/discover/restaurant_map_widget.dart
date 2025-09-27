import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class RestaurantMapWidget extends StatefulWidget {
  final Function(Map<String, dynamic>)? onRestaurantSelected;
  final Function(Offset)? onMapTap;
  final List<String> filterCuisines;
  final List<String> filterPriceRanges;
  final bool showAvailableSessions;
  final bool showUserSessions;

  const RestaurantMapWidget({
    super.key,
    this.onRestaurantSelected,
    this.onMapTap,
    this.filterCuisines = const [],
    this.filterPriceRanges = const [],
    this.showAvailableSessions = true,
    this.showUserSessions = false,
  });

  @override
  State<RestaurantMapWidget> createState() => _RestaurantMapWidgetState();
}

class _RestaurantMapWidgetState extends State<RestaurantMapWidget> {
  List<Map<String, dynamic>> _filteredRestaurants = [];
  Map<String, dynamic>? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  @override
  void didUpdateWidget(RestaurantMapWidget oldWidget) {
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
      restaurants = restaurants.where((restaurant) =>
        widget.filterCuisines.contains(restaurant['cuisine'])
      ).toList();
    }

    if (widget.filterPriceRanges.isNotEmpty) {
      restaurants = restaurants.where((restaurant) =>
        widget.filterPriceRanges.contains(restaurant['priceRange'])
      ).toList();
    }

    setState(() {
      _filteredRestaurants = restaurants;
    });
  }

  void _onRestaurantTapped(Map<String, dynamic> restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
    });
    widget.onRestaurantSelected?.call(restaurant);
  }

  void _onMapTapped() {
    setState(() {
      _selectedRestaurant = null;
    });
    widget.onMapTap?.call(const Offset(0, 0));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onMapTapped,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.green.shade50,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Map placeholder background
            Container(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: MapGridPainter(),
              ),
            ),

            // Map placeholder text
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Map Placeholder',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Google Maps integration coming soon',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Restaurant markers
            ..._buildRestaurantMarkers(),

            // Location button
            Positioned(
              right: 16,
              bottom: 100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    // Placeholder for location functionality
                  },
                  icon: const Icon(Icons.my_location, color: Colors.grey),
                  tooltip: 'Go to current location',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRestaurantMarkers() {
    final List<Widget> markers = [];

    for (int i = 0; i < _filteredRestaurants.length && i < 6; i++) {
      final restaurant = _filteredRestaurants[i];
      final isSelected = _selectedRestaurant != null &&
                        _selectedRestaurant!['id'] == restaurant['id'];

      // Position markers in a grid pattern
      final double left = 50.0 + (i % 3) * 100.0;
      final double top = 150.0 + (i ~/ 3) * 100.0;

      markers.add(
        Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            onTap: () => _onRestaurantTapped(restaurant),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.red : _getMarkerColor(restaurant),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getMarkerIcon(restaurant),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  Color _getMarkerColor(Map<String, dynamic> restaurant) {
    if (widget.showAvailableSessions) {
      // Check if restaurant has available sessions
      return Colors.green;
    }
    if (widget.showUserSessions) {
      // Check if user has sessions here
      return Colors.blue;
    }
    return Colors.orange;
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
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);

      final y = (size.height / 20) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}