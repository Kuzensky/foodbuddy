import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/matches/matches_controller.dart';
import '../widgets/matches/matches_toggle_widget.dart';
import '../widgets/matches/active_session_card.dart';
import '../widgets/matches/pending_request_card.dart';
import '../widgets/matches/matches_empty_state.dart';
import '../widgets/social/skeleton_loading.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with TickerProviderStateMixin {
  late MatchesController _controller;
  late AnimationController _fadeInController;
  late AnimationController _modeTransitionController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;
  final Map<String, AnimationController> _cardControllers = {};
  final Map<String, Animation<double>> _cardAnimations = {};

  @override
  void initState() {
    super.initState();
    _controller = MatchesController();
    _initializeAnimations();
    _initializeController();
  }

  void _initializeAnimations() {
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _modeTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modeTransitionController,
      curve: Curves.easeInOutCubic,
    ));
  }

  void _initializeController() async {
    await _controller.initialize();
    if (mounted) {
      _fadeInController.forward();
      _modeTransitionController.forward();
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _modeTransitionController.dispose();
    _controller.dispose();
    for (final controller in _cardControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _controller.refresh();
  }

  AnimationController _getCardController(String requestId) {
    if (!_cardControllers.containsKey(requestId)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutBack,
      ));

      _cardControllers[requestId] = controller;
      _cardAnimations[requestId] = animation;
      _controller.registerCardController(requestId, controller, animation);
    }
    return _cardControllers[requestId]!;
  }

  void _toggleCardExpansion(String requestId) {
    final controller = _getCardController(requestId);
    _controller.toggleCardExpansion(requestId, controller);
  }

  void _acceptRequest(Map<String, dynamic> request) async {
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
            Text('Accepting request...'),
          ],
        ),
        duration: Duration(milliseconds: 1500),
      ),
    );

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1000));

    await _controller.acceptRequest(request);

    // Clean up animation controller
    if (_cardControllers.containsKey(request['id'])) {
      _cardControllers[request['id']]!.dispose();
      _cardControllers.remove(request['id']);
      _cardAnimations.remove(request['id']);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text('${request['user']['name']} accepted!'),
            ],
          ),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _rejectRequest(Map<String, dynamic> request) async {
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
            Text('Processing...'),
          ],
        ),
        duration: Duration(milliseconds: 1200),
      ),
    );

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    await _controller.rejectRequest(request);

    // Clean up animation controller
    if (_cardControllers.containsKey(request['id'])) {
      _cardControllers[request['id']]!.dispose();
      _cardControllers.remove(request['id']);
      _cardAnimations.remove(request['id']);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.cancel,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text('Request declined'),
            ],
          ),
          backgroundColor: Colors.grey.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openMessageScreen(Map<String, dynamic> user) {
    // Navigate to message screen with the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${user['name']}...'),
        duration: const Duration(seconds: 2),
      ),
    );
    _controller.openMessageScreen(user);
    // TODO: Implement navigation to messaging screen
    // Navigator.pushNamed(context, '/message', arguments: {'userId': user['id']});
  }

  void _onModeChanged(bool isActiveMode) {
    _controller.setMode(isActiveMode);
    _modeTransitionController.reset();
    _modeTransitionController.forward();
  }

  void _onEmptyStateAction() {
    if (_controller.isActiveMode && _controller.pendingRequests.isNotEmpty) {
      _controller.setMode(false);
    } else if (!_controller.isActiveMode && _controller.activeSessions.isNotEmpty) {
      _controller.setMode(true);
    } else {
      // Navigate to discover screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigate to Discover to create sessions!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Matches',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
        body: Consumer<MatchesController>(
          builder: (context, controller, child) {
            return controller.isLoading
                ? _buildLoadingState()
                : _buildContent(controller);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: LoadingListSkeleton(
        itemCount: 4,
        itemBuilder: () => const MatchCardSkeleton(),
      ),
    );
  }

  Widget _buildContent(MatchesController controller) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Column(
        children: [
          // Toggle widget
          MatchesToggleWidget(
            isActiveMode: controller.isActiveMode,
            onModeChanged: _onModeChanged,
          ),
          // Content area
          Expanded(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.2, 0),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: FadeTransition(
                opacity: _slideAnimation,
                child: controller.hasData
                    ? _buildList(controller)
                    : MatchesEmptyState(
                        isActiveMode: controller.isActiveMode,
                        onActionPressed: _onEmptyStateAction,
                        pendingCount: controller.pendingRequests.length,
                        activeCount: controller.activeSessions.length,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(MatchesController controller) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Colors.black87,
      child: CustomScrollView(
        slivers: [
          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Text(
                    controller.currentModeTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      controller.currentCount.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Cards list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final request = controller.currentList[index];
                  final isExpanded = controller.expandedRequestId == request['id'];
                  final animation = controller.getCardAnimation(request['id']);

                  if (controller.isActiveMode) {
                    return ActiveSessionCard(
                      request: request,
                      isExpanded: isExpanded,
                      animation: animation,
                      onTap: () => _toggleCardExpansion(request['id']),
                      onMessage: () => _openMessageScreen(request['user']),
                    );
                  } else {
                    return PendingRequestCard(
                      request: request,
                      isExpanded: isExpanded,
                      animation: animation,
                      onTap: () => _toggleCardExpansion(request['id']),
                      onAccept: () => _acceptRequest(request),
                      onReject: () => _rejectRequest(request),
                    );
                  }
                },
                childCount: controller.currentList.length,
              ),
            ),
          ),
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }






}