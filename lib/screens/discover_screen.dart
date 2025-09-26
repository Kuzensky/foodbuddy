import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with TickerProviderStateMixin {
  // Controllers for animations
  late AnimationController _fadeController;
  late AnimationController _toggleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State variables
  bool _isCreateMode = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _availableSessions = [];
  String? _expandedSessionId;

  // Create mode state
  bool _showCreateForm = false;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Map<String, dynamic>? _selectedRestaurant;
  DateTime? _selectedDateTime;
  int _maxParticipants = 4;
  List<String> _selectedFoodTypes = [];
  List<int> _ageRange = [18, 65];
  List<int> _priceRange = [10, 100];
  final List<String> _dietaryRestrictions = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDiscoverData();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _toggleController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDiscoverData() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _availableSessions = DummyData.getOpenSessions()
          .where((session) => session['hostUserId'] != CurrentUser.userId)
          .toList();
      _isLoading = false;
    });

    _fadeController.forward();
  }

  void _toggleMode() {
    setState(() {
      _isCreateMode = !_isCreateMode;
      _expandedSessionId = null;
      _showCreateForm = false;
      _resetCreateForm();
    });

    _toggleController.forward().then((_) {
      _toggleController.reset();
    });
  }

  void _resetCreateForm() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedRestaurant = null;
    _selectedDateTime = null;
    _maxParticipants = 4;
    _selectedFoodTypes.clear();
    _ageRange = [18, 65];
    _priceRange = [10, 100];
    _dietaryRestrictions.clear();
  }

  void _showFilterOptions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.map, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text('Restaurant map with filters coming soon!'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _joinSession(Map<String, dynamic> session) async {
    // Show loading state
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Joining session...'),
          ],
        ),
        duration: Duration(milliseconds: 1500),
      ),
    );

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Join request sent for "${session['title']}"!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _passSession(Map<String, dynamic> session) {
    setState(() {
      _availableSessions.removeWhere((s) => s['id'] == session['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Passed on "${session['title']}"'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d from now';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h from now';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m from now';
    } else {
      return 'Starting soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildToggleSection(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildContent(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'FoodBuddy',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: Colors.blue.shade600,
              size: 22,
            ),
            onPressed: _showFilterOptions,
            tooltip: 'Filter restaurants',
          ),
        ),
      ],
    );
  }

  Widget _buildToggleSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => !_isCreateMode ? null : _toggleMode(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isCreateMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isCreateMode
                      ? [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Discover',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: !_isCreateMode ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _isCreateMode ? null : _toggleMode(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isCreateMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isCreateMode
                      ? [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Create',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isCreateMode ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading sessions...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _isCreateMode ? _buildCreateMode() : _buildDiscoverMode(),
      ),
    );
  }

  Widget _buildDiscoverMode() {
    if (_availableSessions.isEmpty) {
      return _buildEmptyDiscoverState();
    }

    return RefreshIndicator(
      onRefresh: _loadDiscoverData,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Text(
                    'Available Sessions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _availableSessions.length.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final session = _availableSessions[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: index == _availableSessions.length - 1 ? 32 : 0,
                  ),
                  child: _buildSessionCard(session),
                );
              },
              childCount: _availableSessions.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final host = DummyData.getUserById(session['hostUserId']);
    final restaurant = DummyData.getRestaurantById(session['restaurantId']);
    final isExpanded = _expandedSessionId == session['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedSessionId = isExpanded ? null : session['id'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main card content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with host info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade100,
                        child: host != null
                            ? Text(
                                _getInitials(host['name']),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            : const Icon(Icons.person, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  host?['name'] ?? 'Host',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                if (host?['isVerified'] == true) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 8,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (host != null)
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Colors.amber.shade600,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${host['rating']} rating',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Session title and description
                  Text(
                    session['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    session['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded ? null : TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  // Quick info row
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.restaurant,
                        restaurant?['name'] ?? 'Restaurant',
                        Colors.orange.shade100,
                        Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.people,
                        '${session['currentParticipants']}/${session['maxParticipants']}',
                        Colors.blue.shade100,
                        Colors.blue.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateTime(session['scheduledTime']),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Expandable content
            if (isExpanded) _buildExpandedSessionContent(session, host, restaurant),
            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _passSession(session),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Pass'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _joinSession(session),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Join Session'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.green.shade200),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSessionContent(
    Map<String, dynamic> session,
    Map<String, dynamic>? host,
    Map<String, dynamic>? restaurant,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant details
          if (restaurant != null) ...[
            _buildDetailSection(
              'Restaurant Details',
              [
                _buildDetailRow(Icons.restaurant_menu,
                    '${restaurant['cuisine']} • ${restaurant['priceRange']}'),
                _buildDetailRow(Icons.location_on, restaurant['address']),
                _buildDetailRow(Icons.star,
                    '${restaurant['rating']} (${restaurant['reviewCount']} reviews)'),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // Session preferences
          if (session['preferences'] != null) ...[
            _buildDetailSection(
              'Session Preferences',
              [
                if (session['preferences']['ageRange'] != null)
                  _buildDetailRow(Icons.cake,
                      'Age: ${session['preferences']['ageRange'][0]}-${session['preferences']['ageRange'][1]}'),
                if (session['preferences']['priceRange'] != null)
                  _buildDetailRow(Icons.attach_money,
                      'Budget: \$${session['preferences']['priceRange'][0]}-\$${session['preferences']['priceRange'][1]}'),
                if (session['preferences']['foodTypes'] != null &&
                    (session['preferences']['foodTypes'] as List).isNotEmpty)
                  _buildDetailRow(Icons.fastfood,
                      'Food: ${(session['preferences']['foodTypes'] as List).join(', ')}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDiscoverState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Sessions Available',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Be the first to create a meal session!\nOther food lovers are waiting to join.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: _toggleMode,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add,
                      size: 18,
                      color: Colors.black87,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Create Session',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateMode() {
    if (!_showCreateForm) {
      return _buildCreateModeIntro();
    }

    return _buildCreateForm();
  }

  Widget _buildCreateModeIntro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_circle_outline,
                size: 48,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Create a Meal Session',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bring food lovers together! Create a session, choose your restaurant, and set your preferences for the perfect dining experience.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showCreateForm = true;
                  });
                },
                icon: const Icon(Icons.restaurant, size: 20),
                label: const Text('Start Creating'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green.shade200),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showCreateForm = false;
                    _resetCreateForm();
                  });
                },
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              const Text(
                'Create New Session',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Basic Details Section
          _buildFormSection(
            'Basic Details',
            [
              _buildTextInput(
                controller: _titleController,
                label: 'Session Title',
                hint: 'e.g., Italian Food Adventure',
                icon: Icons.title,
              ),
              const SizedBox(height: 16),
              _buildTextInput(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Tell others what to expect from this dining experience...',
                icon: Icons.description,
                maxLines: 3,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Restaurant Selection
          _buildFormSection(
            'Restaurant Selection',
            [
              _buildRestaurantSelector(),
            ],
          ),

          const SizedBox(height: 24),

          // Date & Time
          _buildFormSection(
            'Schedule',
            [
              _buildDateTimeSelector(),
            ],
          ),

          const SizedBox(height: 24),

          // Group Size
          _buildFormSection(
            'Group Size',
            [
              _buildParticipantSelector(),
            ],
          ),

          const SizedBox(height: 24),

          // Preferences
          _buildFormSection(
            'Session Preferences',
            [
              _buildPreferencesSection(),
            ],
          ),

          const SizedBox(height: 32),

          // Create Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _canCreateSession() ? _createSession : null,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFormSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildTextInput({
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
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildRestaurantSelector() {
    return GestureDetector(
      onTap: _showRestaurantPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.restaurant, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: _selectedRestaurant != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedRestaurant!['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedRestaurant!['cuisine']} • ${_selectedRestaurant!['address']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Select a restaurant',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
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
                  fontWeight: _selectedDateTime != null
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade400),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _maxParticipants.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
            activeColor: Colors.green.shade600,
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
    return Column(
      children: [
        // Food Types
        _buildMultiSelect(
          title: 'Food Types',
          options: ['Italian', 'Asian', 'Mexican', 'American', 'Mediterranean', 'Vegetarian', 'Vegan'],
          selectedOptions: _selectedFoodTypes,
          onChanged: (selected) {
            setState(() {
              _selectedFoodTypes = selected;
            });
          },
        ),
        const SizedBox(height: 16),
        // Price Range
        _buildRangeSelector(
          title: 'Price Range (\$)',
          currentRange: _priceRange,
          min: 5,
          max: 200,
          onChanged: (range) {
            setState(() {
              _priceRange = range;
            });
          },
        ),
        const SizedBox(height: 16),
        // Age Range
        _buildRangeSelector(
          title: 'Age Range',
          currentRange: _ageRange,
          min: 18,
          max: 80,
          onChanged: (range) {
            setState(() {
              _ageRange = range;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMultiSelect({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(List<String>) onChanged,
  }) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);
              return GestureDetector(
                onTap: () {
                  final newSelection = List<String>.from(selectedOptions);
                  if (isSelected) {
                    newSelection.remove(option);
                  } else {
                    newSelection.add(option);
                  }
                  onChanged(newSelection);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.green.shade300 : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.green.shade700 : Colors.grey.shade600,
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

  Widget _buildRangeSelector({
    required String title,
    required List<int> currentRange,
    required int min,
    required int max,
    required Function(List<int>) onChanged,
  }) {
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
          Text(
            '$title: ${currentRange[0]} - ${currentRange[1]}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          RangeSlider(
            values: RangeValues(currentRange[0].toDouble(), currentRange[1].toDouble()),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            activeColor: Colors.green.shade600,
            onChanged: (values) {
              onChanged([values.start.round(), values.end.round()]);
            },
          ),
        ],
      ),
    );
  }

  void _showRestaurantPicker() {
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
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Select Restaurant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: DummyData.restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = DummyData.restaurants[index];
                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    title: Text(
                      restaurant['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${restaurant['cuisine']} • ${restaurant['priceRange']}\n${restaurant['address']}',
                    ),
                    isThreeLine: true,
                    onTap: () {
                      setState(() {
                        _selectedRestaurant = restaurant;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
           _selectedRestaurant != null &&
           _selectedDateTime != null;
  }

  void _createSession() async {
    // Show loading state
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Creating session...'),
          ],
        ),
        duration: Duration(milliseconds: 2000),
      ),
    );

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Session "${_titleController.text}" created successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Reset form and switch back to discover mode
      setState(() {
        _showCreateForm = false;
        _isCreateMode = false;
        _resetCreateForm();
      });

      // Reload data
      _loadDiscoverData();
    }
  }
}