import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../widgets/discover/google_map_widget.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  bool _isCreateMode = false;
  bool _showMap = false;
  List<String> _selectedCuisines = [];
  List<String> _selectedPriceRanges = [];
  List<Map<String, dynamic>> _filteredSessions = [];

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    try {
      _filteredSessions = _isCreateMode
          ? DummyData.getSessionsByUserId(CurrentUser.userId) ?? []
          : DummyData.mealSessions ?? [];
    } catch (e) {
      _filteredSessions = [];
    }
    setState(() {});
  }

  void _onModeChanged(bool isCreateMode) {
    setState(() {
      _isCreateMode = isCreateMode;
      _showMap = false;
    });
    _loadSessions();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        selectedCuisines: _selectedCuisines,
        selectedPriceRanges: _selectedPriceRanges,
        onFiltersApplied: (cuisines, priceRanges) {
          setState(() {
            _selectedCuisines = cuisines;
            _selectedPriceRanges = priceRanges;
            _showMap = cuisines.isNotEmpty || priceRanges.isNotEmpty;
          });
          _loadSessions();
        },
      ),
    );
  }

  void _toggleMapView() {
    setState(() {
      _showMap = !_showMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Discover',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _showMap ? Icons.list : Icons.map_outlined,
                color: Colors.black87,
                size: 20,
              ),
            ),
            onPressed: _toggleMapView,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.filter_list,
                color: Colors.black87,
                size: 20,
              ),
            ),
            onPressed: _showFilterBottomSheet,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Mode toggle
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onModeChanged(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isCreateMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !_isCreateMode ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Text(
                        'Discover',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: !_isCreateMode ? Colors.black87 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onModeChanged(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isCreateMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _isCreateMode ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: Text(
                        'My Sessions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _isCreateMode ? Colors.black87 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _showMap && (_isCreateMode || _selectedCuisines.isNotEmpty || _selectedPriceRanges.isNotEmpty)
                ? _buildMapView()
                : _buildSessionsList(),
          ),
        ],
      ),
      floatingActionButton: _isCreateMode ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _showMap = true;
          });
        },
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildMapView() {
    return GoogleMapWidget(
      onRestaurantSelected: (restaurant) {
        // Handle restaurant selection for creating sessions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected ${restaurant['name']}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onMapTap: (position) {
        // Handle map tap
      },
      filterCuisines: _selectedCuisines,
      filterPriceRanges: _selectedPriceRanges,
      showAvailableSessions: !_isCreateMode,
      showUserSessions: _isCreateMode,
    );
  }

  Widget _buildSessionsList() {
    if (_filteredSessions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadSessions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredSessions.length,
        itemBuilder: (context, index) {
          return _buildSessionCard(_filteredSessions[index]);
        },
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final restaurant = DummyData.getRestaurantById(session['restaurantId'] ?? '');
    final creator = DummyData.getUserById(session['hostUserId'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          // Restaurant image placeholder
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant?['name'] ?? 'Restaurant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Session info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        session['title'] ?? 'Meal Session',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${session['participants']?.length ?? 0}/${session['maxParticipants'] ?? 4}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  session['description'] ?? 'Join us for a great meal!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(session['scheduledTime']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'by ${creator?['name'] ?? 'User'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Handle join session
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Join request sent for "${session['title']}"!'),
                              backgroundColor: Colors.black87,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Join',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle view details
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Viewing details for "${session['title']}"'),
                              backgroundColor: Colors.black87,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Details'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
              _isCreateMode ? Icons.add_circle_outline : Icons.search,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isCreateMode ? 'No Sessions Created' : 'No Sessions Available',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _isCreateMode
                  ? 'Start creating meal sessions!\nTap the + button to begin.'
                  : 'Be the first to create a meal session!\nOther food lovers are waiting to join.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (!_isCreateMode)
            ElevatedButton.icon(
              onPressed: () => _onModeChanged(true),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'TBD';
    try {
      final dt = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = dt.difference(now);

      if (difference.inDays > 0) {
        return '${difference.inDays}d from now';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h from now';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m from now';
      } else {
        return 'Now';
      }
    } catch (e) {
      return 'TBD';
    }
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final List<String> selectedCuisines;
  final List<String> selectedPriceRanges;
  final Function(List<String>, List<String>) onFiltersApplied;

  const _FilterBottomSheet({
    required this.selectedCuisines,
    required this.selectedPriceRanges,
    required this.onFiltersApplied,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late List<String> _selectedCuisines;
  late List<String> _selectedPriceRanges;

  final List<String> _cuisineOptions = [
    'Italian', 'Asian', 'Mexican', 'American', 'Mediterranean', 'Indian', 'Japanese', 'Thai'
  ];

  final List<String> _priceRangeOptions = [
    '\$', '\$\$', '\$\$\$', '\$\$\$\$'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCuisines = List.from(widget.selectedCuisines);
    _selectedPriceRanges = List.from(widget.selectedPriceRanges);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Sessions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Cuisine Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _cuisineOptions.map((cuisine) {
                    final isSelected = _selectedCuisines.contains(cuisine);
                    return FilterChip(
                      label: Text(cuisine),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCuisines.add(cuisine);
                          } else {
                            _selectedCuisines.remove(cuisine);
                          }
                        });
                      },
                      selectedColor: Colors.black87,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Price Range',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _priceRangeOptions.map((price) {
                    final isSelected = _selectedPriceRanges.contains(price);
                    return FilterChip(
                      label: Text(price),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPriceRanges.add(price);
                          } else {
                            _selectedPriceRanges.remove(price);
                          }
                        });
                      },
                      selectedColor: Colors.black87,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCuisines.clear();
                            _selectedPriceRanges.clear();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onFiltersApplied(_selectedCuisines, _selectedPriceRanges);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}