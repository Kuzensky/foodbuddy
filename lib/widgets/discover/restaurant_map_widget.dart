import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';

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
    // Create 5 sample restaurants near user location
    final sampleRestaurants = [
      {
        'id': 'rest_1',
        'name': 'Pizza Palace',
        'cuisine': 'Italian',
        'priceRange': '₱₱',
        'rating': 4.5,
        'distance': '0.3 km',
        'imageUrl': null,
        'latitude': 13.7659,
        'longitude': 121.0581,
      },
      {
        'id': 'rest_2',
        'name': 'Sushi Zen',
        'cuisine': 'Japanese',
        'priceRange': '₱₱₱',
        'rating': 4.8,
        'distance': '0.5 km',
        'imageUrl': null,
        'latitude': 13.7665,
        'longitude': 121.0575,
      },
      {
        'id': 'rest_3',
        'name': 'Burger Joint',
        'cuisine': 'American',
        'priceRange': '₱₱',
        'rating': 4.2,
        'distance': '0.7 km',
        'imageUrl': null,
        'latitude': 13.7670,
        'longitude': 121.0590,
      },
      {
        'id': 'rest_4',
        'name': 'Taco Express',
        'cuisine': 'Mexican',
        'priceRange': '₱',
        'rating': 4.0,
        'distance': '0.8 km',
        'imageUrl': null,
        'latitude': 13.7655,
        'longitude': 121.0595,
      },
      {
        'id': 'rest_5',
        'name': 'Green Garden',
        'cuisine': 'Vegan',
        'priceRange': '₱₱₱',
        'rating': 4.6,
        'distance': '1.0 km',
        'imageUrl': null,
        'latitude': 13.7650,
        'longitude': 121.0570,
      },
    ];

    var restaurants = List<Map<String, dynamic>>.from(sampleRestaurants);

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
            SizedBox(
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
              bottom: _selectedRestaurant != null ? 220 : 100,
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

            // Session Creation Panel
            if (_selectedRestaurant != null) _buildSessionCreationPanel(),
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
                color: isSelected ? const Color(0xFFEF4444) : _getMarkerColor(restaurant), // Red for selected
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 0),
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
      // Check if restaurant has available sessions - vibrant green
      return const Color(0xFF10B981); // Emerald green
    }
    if (widget.showUserSessions) {
      // Check if user has sessions here - app blue
      return const Color(0xFF3B82F6); // Bright blue
    }
    // Default restaurant color - warm orange
    return const Color(0xFFF59E0B); // Amber orange
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

  Widget _buildSessionCreationPanel() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Info Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedRestaurant!['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_selectedRestaurant!['rating']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedRestaurant!['cuisine'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedRestaurant!['distance'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedRestaurant = null;
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Session Creation Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.group_add,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Create Meal Session',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start a meal session at ${_selectedRestaurant!['name']} and invite others to join!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Session Options
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _createQuickSession(),
                          icon: const Icon(Icons.flash_on, size: 18),
                          label: const Text('Quick Session'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _createCustomSession(),
                          icon: const Icon(Icons.settings, size: 18),
                          label: const Text('Customize'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createQuickSession() async {
    if (_selectedRestaurant == null) return;

    try {
      final databaseProvider = context.read<DatabaseProvider>();

      final sessionData = {
        'restaurantId': _selectedRestaurant!['id'],
        'restaurantName': _selectedRestaurant!['name'],
        'maxParticipants': 4,
        'scheduledTime': DateTime.now().add(const Duration(hours: 1)),
        'description': 'Quick meal session at ${_selectedRestaurant!['name']}',
        'restaurant': _selectedRestaurant,
      };

      await databaseProvider.createMealSession(sessionData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quick session created at ${_selectedRestaurant!['name']}!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to sessions screen
                Navigator.of(context).pushNamed('/sessions');
              },
            ),
          ),
        );

        // Clear selection after successful creation
        setState(() {
          _selectedRestaurant = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create session: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createCustomSession() {
    if (_selectedRestaurant == null) return;

    showDialog(
      context: context,
      builder: (context) => _CustomSessionDialog(
        restaurant: _selectedRestaurant!,
        onSessionCreated: () {
          setState(() {
            _selectedRestaurant = null;
          });
        },
      ),
    );
  }
}

class _CustomSessionDialog extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onSessionCreated;

  const _CustomSessionDialog({
    required this.restaurant,
    required this.onSessionCreated,
  });

  @override
  State<_CustomSessionDialog> createState() => _CustomSessionDialogState();
}

class _CustomSessionDialogState extends State<_CustomSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  int _maxParticipants = 4;
  DateTime _scheduledTime = DateTime.now().add(const Duration(hours: 1));
  bool _isCreating = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Session at ${widget.restaurant['name']}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Session Description',
                  hintText: 'Tell others about your meal plans...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _maxParticipants,
                decoration: const InputDecoration(
                  labelText: 'Max Participants',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(8, (index) => index + 2)
                    .map((count) => DropdownMenuItem(
                          value: count,
                          child: Text('$count people'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _maxParticipants = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Scheduled Time'),
                subtitle: Text(_formatDateTime(_scheduledTime)),
                trailing: const Icon(Icons.access_time),
                onTap: _selectDateTime,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createSession,
          child: _isCreating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Session'),
        ),
      ],
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledTime),
      );

      if (time != null && mounted) {
        setState(() {
          _scheduledTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _createSession() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final databaseProvider = context.read<DatabaseProvider>();

      final sessionData = {
        'restaurantId': widget.restaurant['id'],
        'restaurantName': widget.restaurant['name'],
        'maxParticipants': _maxParticipants,
        'scheduledTime': _scheduledTime,
        'description': _descriptionController.text.trim(),
        'restaurant': widget.restaurant,
      };

      await databaseProvider.createMealSession(sessionData);

      if (mounted) {
        Navigator.pop(context);
        widget.onSessionCreated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Custom session created at ${widget.restaurant['name']}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create session: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (sessionDate == today) {
      dateStr = 'Today';
    } else if (sessionDate == today.add(const Duration(days: 1))) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
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