import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class SlidingBottomPanel extends StatefulWidget {
  final Map<String, dynamic>? selectedRestaurant;
  final bool isCreateMode;
  final VoidCallback? onClose;
  final Function(Map<String, dynamic>)? onSessionCreated;
  final Function(Map<String, dynamic>)? onJoinSession;

  const SlidingBottomPanel({
    super.key,
    this.selectedRestaurant,
    this.isCreateMode = false,
    this.onClose,
    this.onSessionCreated,
    this.onJoinSession,
  });

  @override
  State<SlidingBottomPanel> createState() => _SlidingBottomPanelState();
}

class _SlidingBottomPanelState extends State<SlidingBottomPanel>
    with TickerProviderStateMixin {

  final DraggableScrollableController _panelController =
      DraggableScrollableController();

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Form state
  DateTime? _selectedDateTime;
  int _maxParticipants = 4;
  final List<String> _selectedFoodTypes = [];
  final List<int> _ageRange = [18, 65];
  final List<int> _priceRange = [10, 100];

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;

  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // Auto-expand when restaurant is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedRestaurant != null) {
        _expandPanel();
      }
    });
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _panelController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SlidingBottomPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedRestaurant != null &&
        oldWidget.selectedRestaurant != widget.selectedRestaurant) {
      _expandPanel();
    } else if (widget.selectedRestaurant == null &&
               oldWidget.selectedRestaurant != null) {
      _collapsePanel();
    }
  }

  void _expandPanel() {
    setState(() {
      // Panel expanded
    });
    _slideController.forward();
    _fadeController.forward();

    _panelController.animateTo(
      0.6, // Expand to 60% of screen height
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _collapsePanel() {
    setState(() {
      // Panel collapsed
      _showForm = false;
    });
    _slideController.reverse();
    _fadeController.reverse();

    _panelController.animateTo(
      0.1, // Collapse to 10% of screen height
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
    });

    if (_showForm) {
      _panelController.animateTo(
        0.9, // Expand to 90% for form
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _panelController.animateTo(
        0.6,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedRestaurant == null) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      controller: _panelController,
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.1, 0.6, 0.9],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildPanelContent(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPanelContent() {
    if (_showForm && widget.isCreateMode) {
      return _buildSessionForm();
    }

    return _buildRestaurantInfo();
  }

  Widget _buildRestaurantInfo() {
    final restaurant = widget.selectedRestaurant!;
    final sessions = _getSessionsForRestaurant(restaurant['id']);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant header
          _buildRestaurantHeader(restaurant),

          const SizedBox(height: 20),

          // Restaurant details
          _buildRestaurantDetails(restaurant),

          const SizedBox(height: 20),

          // Sessions section
          if (sessions.isNotEmpty) ...[
            _buildSessionsSection(sessions),
            const SizedBox(height: 20),
          ],

          // Action buttons
          _buildActionButtons(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRestaurantHeader(Map<String, dynamic> restaurant) {
    return Row(
      children: [
        // Restaurant image placeholder
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            image: restaurant['imageUrl'] != null
                ? DecorationImage(
                    image: NetworkImage(restaurant['imageUrl']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: restaurant['imageUrl'] == null
              ? Icon(Icons.restaurant, color: Colors.grey.shade400, size: 30)
              : null,
        ),

        const SizedBox(width: 16),

        // Restaurant info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${restaurant['cuisine']} • ${restaurant['priceRange']}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade600, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${restaurant['rating']} (${restaurant['reviewCount']} reviews)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Close button
        IconButton(
          onPressed: widget.onClose,
          icon: Icon(Icons.close, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _buildRestaurantDetails(Map<String, dynamic> restaurant) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.location_on, restaurant['address']),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.phone, restaurant['phone']),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.public, restaurant['website']),
          if (restaurant['description'] != null) ...[
            const SizedBox(height: 12),
            Text(
              restaurant['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsSection(List<Map<String, dynamic>> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Sessions',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...sessions.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final host = {'name': 'Unknown User', 'profileImageUrl': ''};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade100,
                child: Text(
                  host != null ? _getInitials(host['name'] ?? '') : 'H',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  session['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => widget.onJoinSession?.call(session),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('Join', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          if (session['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              session['description'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (!widget.isCreateMode) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // View all sessions for this restaurant
              },
              icon: const Icon(Icons.search, size: 18),
              label: const Text('View All Sessions'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.isCreateMode ? _toggleForm : () {
              setState(() {
                _showForm = true;
              });
              _toggleForm();
            },
            icon: Icon(_showForm ? Icons.close : Icons.add, size: 18),
            label: Text(_showForm ? 'Cancel' : 'Create Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionForm() {
    return AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 300),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: _toggleForm,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Create Session',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Session title
              _buildTextField(
                controller: _titleController,
                label: 'Session Title',
                hint: 'e.g., Italian Food Adventure',
                icon: Icons.title,
              ),

              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Tell others what to expect...',
                icon: Icons.description,
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // Date & Time
              _buildDateTimeSelector(),

              const SizedBox(height: 20),

              // Participants
              _buildParticipantSelector(),

              const SizedBox(height: 20),

              // Food preferences
              _buildFoodPreferencesSelector(),

              const SizedBox(height: 30),

              // Create button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canCreateSession() ? _createSession : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Session',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return GestureDetector(
      onTap: _showDateTimePicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDateTime != null
                    ? 'Selected: ${_selectedDateTime!.day}/${_selectedDateTime!.month} at ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}'
                    : 'Select date and time',
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedDateTime != null
                      ? Colors.black87
                      : Colors.grey.shade600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Text(
                'Maximum participants: $_maxParticipants',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Slider(
            value: _maxParticipants.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
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

  Widget _buildFoodPreferencesSelector() {
    const foodTypes = [
      'Italian', 'Asian', 'Mexican', 'American', 'Mediterranean',
      'Vegetarian', 'Vegan', 'Seafood', 'BBQ'
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Food Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: foodTypes.map((type) {
              final isSelected = _selectedFoodTypes.contains(type);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFoodTypes.remove(type);
                    } else {
                      _selectedFoodTypes.add(type);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black87 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.black87 : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showDateTimePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 19, minute: 0),
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

  bool _canCreateSession() {
    return _titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _selectedDateTime != null;
  }

  void _createSession() {
    if (!_canCreateSession()) return;

    final session = {
      'id': 'session_${DateTime.now().millisecondsSinceEpoch}',
      'hostUserId': 'current_user',
      'title': _titleController.text,
      'description': _descriptionController.text,
      'restaurantId': widget.selectedRestaurant!['id'],
      'scheduledTime': _selectedDateTime!.toIso8601String(),
      'maxParticipants': _maxParticipants,
      'currentParticipants': 1,
      'status': 'open',
      'preferences': {
        'foodTypes': _selectedFoodTypes,
        'ageRange': _ageRange,
        'priceRange': _priceRange,
      },
      'joinedUsers': [],
      'pendingUsers': [],
      'createdAt': DateTime.now().toIso8601String(),
    };

    widget.onSessionCreated?.call(session);

    // Reset form
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedDateTime = null;
      _maxParticipants = 4;
      _selectedFoodTypes.clear();
      _showForm = false;
    });

    _collapsePanel();
  }

  List<Map<String, dynamic>> _getSessionsForRestaurant(String restaurantId) {
    final sessions = <Map<String, dynamic>>[];
    return sessions.where((session) =>
      session['restaurantId'] == restaurantId &&
      session['hostUserId'] != 'current_user'
    ).toList();
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}