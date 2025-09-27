import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../widgets/discover/flutter_map_widget.dart';
import '../widgets/common/unified_session_card.dart';

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
          ? DummyData.getSessionsByUserId(CurrentUser.userId)
          : DummyData.mealSessions;
    } catch (e) {
      _filteredSessions = [];
    }
    setState(() {});
  }

  void _onJoinSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Join request sent for "${session['title']}"!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onPassSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Passed on "${session['title']}"'),
        backgroundColor: Colors.grey,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCancelSession(Map<String, dynamic> session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Session'),
        content: Text('Are you sure you want to cancel "${session['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cancelled "${session['title']}"'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
              _loadSessions(); // Refresh the list
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onShareSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${session['title']}"...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onInviteToSession(Map<String, dynamic> session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inviting friends to "${session['title']}"...'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
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
    );
  }

  Widget _buildMapView() {
    return FlutterMapWidget(
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
    if (_filteredSessions.isEmpty && !_isCreateMode) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadSessions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _isCreateMode ? _filteredSessions.length + 1 : _filteredSessions.length,
        itemBuilder: (context, index) {
          // Show create session card first in create mode
          if (_isCreateMode && index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildCreateSessionCard(),
            );
          }

          // Adjust index for sessions when create card is shown
          final sessionIndex = _isCreateMode ? index - 1 : index;

          if (sessionIndex >= 0 && sessionIndex < _filteredSessions.length) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: UnifiedSessionCard(
                session: _filteredSessions[sessionIndex],
                cardType: _isCreateMode ? SessionCardType.create : SessionCardType.discover,
                animationIndex: sessionIndex,
                isCompact: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected session "${_filteredSessions[sessionIndex]['title']}"'),
                      backgroundColor: Colors.black87,
                    ),
                  );
                },
                onJoin: _isCreateMode ? null : () {
                  _onJoinSession(_filteredSessions[sessionIndex]);
                },
                onPass: _isCreateMode ? null : () {
                  _onPassSession(_filteredSessions[sessionIndex]);
                },
                onCancel: _isCreateMode ? () {
                  _onCancelSession(_filteredSessions[sessionIndex]);
                } : null,
                onShare: _isCreateMode ? () {
                  _onShareSession(_filteredSessions[sessionIndex]);
                } : null,
                onInvite: _isCreateMode ? () {
                  _onInviteToSession(_filteredSessions[sessionIndex]);
                } : null,
              ),
            );
          }

          // Handle empty state for my sessions
          if (_isCreateMode && _filteredSessions.isEmpty && index == 1) {
            return _buildEmptyMySessionsState();
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }


  Widget _buildCreateSessionCard() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showMap = true;
        });
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade50.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300.withValues(alpha: 0.8),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                color: Colors.grey.shade600.withValues(alpha: 0.9),
                size: 28,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Session',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to select a restaurant and create a meal session',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade500.withValues(alpha: 0.8),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMySessionsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Sessions Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first meal session using the card above',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
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