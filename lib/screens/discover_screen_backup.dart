import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dummy_data.dart';
import '../widgets/discover/restaurant_map_widget.dart';
import '../widgets/discover/sliding_bottom_panel.dart';
import '../widgets/discover/dynamic_appbar.dart';
import '../widgets/discover/mode_toggle_widget.dart';
import '../widgets/discover/modern_session_card.dart';
import '../widgets/discover/discover_controller.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with TickerProviderStateMixin {
  // Controllers
  late DiscoverController _controller;
  late DiscoverAnimationController _animationController;

  // Map widget key for external control
  final GlobalKey<State<RestaurantMapWidget>> _mapKey = GlobalKey();

  // Scroll controller for session list
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = DiscoverController();
    _animationController = DiscoverAnimationController();
    _initializeControllers();
    _setupScrollListener();
  }

  void _initializeControllers() async {
    _animationController.initialize(this);
    await _controller.initialize();
    if (mounted) {
      _animationController.startEntryAnimation();
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      _controller.updateScrollOffset(_scrollController.offset);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onRestaurantSelected(Map<String, dynamic> restaurant) {
    _controller.selectRestaurant(restaurant);
  }

  void _onMapTap(Offset position) {
    _controller.selectRestaurant(null);
  }

  void _onModeChanged(bool isCreateMode) {
    _controller.setCreateMode(isCreateMode);
  }

  void _onSessionCreated(Map<String, dynamic> session) async {
    await _controller.createSession(session);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Session "${session['title']}" created successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onJoinSession(Map<String, dynamic> session) async {
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

    await _controller.joinSession(session);

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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedCuisines: _controller.selectedCuisines,
        selectedPriceRanges: _controller.selectedPriceRanges,
        onFiltersApplied: (cuisines, priceRanges) {
          _controller.updateFilters(cuisines, priceRanges);
        },
      ),
    );
  }

  void _onPassSession(Map<String, dynamic> session) async {
    await _controller.passSession(session);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passed on "${session['title']}"'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _onClosePanel() {
    _controller.selectRestaurant(null);
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<DiscoverController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            extendBodyBehindAppBar: true,
            appBar: DynamicAppBar(
              scrollOffset: controller.scrollOffset,
              isMapInteracting: controller.isMapInteracting,
              onFilterPressed: _showFilterBottomSheet,
            ),
            body: Stack(
              children: [
                // Main content
                _buildMainContent(controller),

                // Mode toggle overlay
                FloatingModeToggle(
                  isCreateMode: controller.isCreateMode,
                  onModeChanged: _onModeChanged,
                ),

                // Sliding bottom panel
                if (controller.selectedRestaurant != null)
                  SlidingBottomPanel(
                    selectedRestaurant: controller.selectedRestaurant,
                    isCreateMode: controller.isCreateMode,
                    onClose: _onClosePanel,
                    onSessionCreated: _onSessionCreated,
                    onJoinSession: _onJoinSession,
                  ),

                // Loading overlay
                if (controller.isLoading)
                  Container(
                    color: Colors.white.withValues(alpha: 0.8),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.black87),
                          SizedBox(height: 16),
                          Text(
                            'Loading restaurants...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(DiscoverController controller) {
    if (controller.isCreateMode && controller.userSessions.isEmpty) {
      return _buildCreateModeMap(controller);
    }

    if (controller.isCreateMode) {
      return _buildUserSessionsList(controller);
    }

    return _buildDiscoverMap(controller);
  }

  Widget _buildDiscoverMap(DiscoverController controller) {
    return RestaurantMapWidget(
      key: _mapKey,
      onRestaurantSelected: _onRestaurantSelected,
      onMapTap: _onMapTap,
      filterCuisines: controller.selectedCuisines,
      filterPriceRanges: controller.selectedPriceRanges,
      showAvailableSessions: true,
      showUserSessions: false,
    );
  }

  Widget _buildCreateModeMap(DiscoverController controller) {
    return RestaurantMapWidget(
      key: _mapKey,
      onRestaurantSelected: _onRestaurantSelected,
      onMapTap: _onMapTap,
      filterCuisines: controller.selectedCuisines,
      filterPriceRanges: controller.selectedPriceRanges,
      showAvailableSessions: false,
      showUserSessions: true,
    );
  }

  Widget _buildUserSessionsList(DiscoverController controller) {
    return Column(
      children: [
        // Map in background (smaller height)
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: RestaurantMapWidget(
            key: _mapKey,
            onRestaurantSelected: _onRestaurantSelected,
            onMapTap: _onMapTap,
            filterCuisines: controller.selectedCuisines,
            filterPriceRanges: controller.selectedPriceRanges,
            showAvailableSessions: false,
            showUserSessions: true,
          ),
        ),

        // Sessions list
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: _buildSessionsList(controller.userSessions),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsList(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    _controller.isCreateMode ? 'Your Sessions' : 'Available Sessions',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sessions.length.toString(),
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
                return ModernSessionCard(
                  session: sessions[index],
                  animationIndex: index,
                  onTap: () => _onRestaurantSelected(
                    DummyData.getRestaurantById(sessions[index]['restaurantId'])!,
                  ),
                  onJoin: () => _onJoinSession(sessions[index]),
                  onPass: () => _onPassSession(sessions[index]),
                );
              },
              childCount: sessions.length,
            ),
          ),
          // Bottom padding for safe area
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 100),
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
              _controller.isCreateMode ? Icons.add_circle_outline : Icons.search,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _controller.isCreateMode ? 'No Sessions Created' : 'No Sessions Available',
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
              _controller.isCreateMode
                  ? 'Start creating meal sessions!\nTap on restaurants on the map to begin.'
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
          if (!_controller.isCreateMode)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => _controller.setCreateMode(true),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 18, color: Colors.black87),
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
}
