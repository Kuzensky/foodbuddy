import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/database_provider.dart';

class CreateSessionScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedRestaurant;

  const CreateSessionScreen({
    super.key,
    this.selectedRestaurant,
  });

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Map<String, dynamic>? _selectedRestaurant;
  DateTime? _selectedDateTime;
  int _maxParticipants = 4;
  RangeValues _ageRange = const RangeValues(18, 50);
  List<String> _selectedFoodTypes = [];
  List<String> _selectedDietaryRestrictions = [];

  bool _isLoading = false;

  final List<String> _foodTypeOptions = [
    'Italian', 'Asian', 'Mexican', 'American', 'Mediterranean',
    'Indian', 'Japanese', 'Thai', 'Korean', 'Chinese', 'French',
    'Vegan', 'Vegetarian', 'Organic', 'Healthy', 'Spicy', 'Meat',
    'Seafood', 'Desserts', 'Chocolate', 'Coffee', 'Wine', 'Sake',
    'Pizza', 'Pasta', 'Sushi', 'BBQ', 'Burgers', 'Tacos'
  ];

  final List<String> _dietaryRestrictionOptions = [
    'No Nuts', 'No Gluten', 'No Dairy', 'Vegan Only', 'Vegetarian Only',
    'No Shellfish', 'No Eggs', 'Halal', 'Kosher', 'Low Sodium', 'Sugar Free'
  ];

  @override
  void initState() {
    super.initState();
    _selectedRestaurant = widget.selectedRestaurant;

    // Pre-populate food types based on restaurant cuisine
    if (_selectedRestaurant != null) {
      final cuisine = _selectedRestaurant!['cuisine']?.toString();
      if (cuisine != null && _foodTypeOptions.contains(cuisine)) {
        _selectedFoodTypes.add(cuisine);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Session',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRestaurantSection(),
                    const SizedBox(height: 24),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildSchedulingSection(),
                    const SizedBox(height: 24),
                    _buildPreferencesSection(),
                    const SizedBox(height: 24),
                    _buildDietaryRestrictionsSection(),
                    const SizedBox(height: 100), // Space for floating button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _createSession,
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.group_add),
          label: Text(
            _isLoading ? 'Creating Session...' : 'Create Session',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildRestaurantSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Restaurant',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedRestaurant != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.restaurant, color: Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedRestaurant!['name'] ?? 'Restaurant',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _selectedRestaurant!['cuisine'] ?? 'Cuisine',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _selectRestaurant,
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: _selectRestaurant,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_location_alt, color: Colors.grey.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select a restaurant',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Session Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Session Title',
              hintText: 'e.g., Italian Food Tasting Night',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a session title';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Tell people what to expect from this session...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.description),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Schedule & Capacity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date and Time
          GestureDetector(
            onTap: _selectDateTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.black87),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Session Date & Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          _selectedDateTime != null
                              ? _formatDateTime(_selectedDateTime!)
                              : 'Select date and time',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedDateTime != null
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Max Participants
          Text(
            'Maximum Participants: $_maxParticipants',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Slider(
            value: _maxParticipants.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
            activeColor: Colors.black87,
            label: '$_maxParticipants people',
            onChanged: (value) {
              setState(() {
                _maxParticipants = value.round();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Age Range
          Text(
            'Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()} years',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          RangeSlider(
            values: _ageRange,
            min: 18,
            max: 65,
            divisions: 47,
            activeColor: Colors.black87,
            labels: RangeLabels(
              '${_ageRange.start.round()}',
              '${_ageRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _ageRange = values;
              });
            },
          ),

          const SizedBox(height: 16),

          // Food Types
          const Text(
            'Food Types/Interests',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _foodTypeOptions.map((type) {
              final isSelected = _selectedFoodTypes.contains(type);
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedFoodTypes.add(type);
                    } else {
                      _selectedFoodTypes.remove(type);
                    }
                  });
                },
                selectedColor: Colors.grey.shade300,
                checkmarkColor: Colors.black87,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black87 : Colors.grey.shade700,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryRestrictionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Dietary Restrictions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select any dietary restrictions for this session',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dietaryRestrictionOptions.map((restriction) {
              final isSelected = _selectedDietaryRestrictions.contains(restriction);
              return FilterChip(
                label: Text(restriction),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDietaryRestrictions.add(restriction);
                    } else {
                      _selectedDietaryRestrictions.remove(restriction);
                    }
                  });
                },
                selectedColor: Colors.grey.shade300,
                checkmarkColor: Colors.black87,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black87 : Colors.grey.shade700,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _selectRestaurant() async {
    // For now, show a simple dialog to select from available restaurants
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    await databaseProvider.loadRestaurants();

    if (!mounted) return;

    final restaurants = databaseProvider.restaurants;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Select Restaurant',
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.restaurant, color: Colors.black87),
                      ),
                      title: Text(restaurant['name'] ?? 'Restaurant'),
                      subtitle: Text(restaurant['cuisine'] ?? 'Cuisine'),
                      trailing: Text(restaurant['priceRange'] ?? '₱₱'),
                      onTap: () {
                        setState(() {
                          _selectedRestaurant = restaurant;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: now.hour + 1,
          minute: 0,
        ),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
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

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year at $hour:$minute';
  }

  void _createSession() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRestaurant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a restaurant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to create a session'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Dismiss keyboard first to prevent navigation issues
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final sessionData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'restaurantId': _selectedRestaurant!['id'],
        'scheduledTime': Timestamp.fromDate(_selectedDateTime!),
        'maxParticipants': _maxParticipants,
        'preferences': {
          'ageRange': [_ageRange.start.round(), _ageRange.end.round()],
          'foodTypes': _selectedFoodTypes,
          'dietaryRestrictions': _selectedDietaryRestrictions,
        },
      };

      // Create session using database provider
      print('🎯 CreateSessionScreen: About to create session');
      print('📋 Session data: $sessionData');

      final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      final sessionId = await databaseProvider.createMealSession(sessionData);
      print('✅ CreateSessionScreen: Session created with ID: $sessionId');

      // Wait a moment for the operation to complete
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Wait a brief moment before navigation to ensure UI is stable
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          // Pop the current screen with success result
          print('🚪 CreateSessionScreen: Navigating back with success result');
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create session: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}