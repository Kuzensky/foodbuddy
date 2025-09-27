import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class MatchesController extends ChangeNotifier {
  // State variables
  bool _isActiveMode = true; // true = Active Sessions, false = Pending Requests
  List<Map<String, dynamic>> _activeSessions = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = true;
  String? _expandedRequestId;

  // Animation controllers map
  final Map<String, AnimationController> _cardControllers = {};
  final Map<String, Animation<double>> _cardAnimations = {};

  // Getters
  bool get isActiveMode => _isActiveMode;
  List<Map<String, dynamic>> get activeSessions => _activeSessions;
  List<Map<String, dynamic>> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get expandedRequestId => _expandedRequestId;

  // Get current list based on mode
  List<Map<String, dynamic>> get currentList =>
      _isActiveMode ? _activeSessions : _pendingRequests;

  // Check if current mode has data
  bool get hasData => currentList.isNotEmpty;

  // Get count for current mode
  int get currentCount => currentList.length;

  // Get mode title
  String get currentModeTitle => _isActiveMode ? 'Active Sessions' : 'Pending Requests';

  // Initialize controller
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    await loadMatchesData();

    _isLoading = false;
    notifyListeners();
  }

  // Load matches data
  Future<void> loadMatchesData() async {
    _pendingRequests = DummyData.getJoinRequestsForCurrentUser();
    _activeSessions = DummyData.getAcceptedJoinRequestsForCurrentUser();
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh() async {
    await loadMatchesData();
  }

  // Toggle between Active Sessions and Pending Requests
  void toggleMode() {
    _isActiveMode = !_isActiveMode;
    _expandedRequestId = null; // Collapse any expanded cards when switching
    notifyListeners();
  }

  // Set specific mode
  void setMode(bool isActiveMode) {
    if (_isActiveMode != isActiveMode) {
      _isActiveMode = isActiveMode;
      _expandedRequestId = null; // Collapse any expanded cards when switching
      notifyListeners();
    }
  }

  // Toggle card expansion
  void toggleCardExpansion(String requestId, AnimationController controller) {
    if (_expandedRequestId == requestId) {
      _expandedRequestId = null;
      controller.reverse();
    } else {
      // Collapse any currently expanded card
      if (_expandedRequestId != null) {
        final previousController = _cardControllers[_expandedRequestId!];
        previousController?.reverse();
      }
      _expandedRequestId = requestId;
      controller.forward();
    }
    notifyListeners();
  }

  // Register animation controller for a card
  void registerCardController(String requestId, AnimationController controller, Animation<double> animation) {
    _cardControllers[requestId] = controller;
    _cardAnimations[requestId] = animation;
  }

  // Unregister animation controller for a card
  void unregisterCardController(String requestId) {
    final controller = _cardControllers[requestId];
    controller?.dispose();
    _cardControllers.remove(requestId);
    _cardAnimations.remove(requestId);
  }

  // Get animation for a card
  Animation<double>? getCardAnimation(String requestId) {
    return _cardAnimations[requestId];
  }

  // Accept a pending request
  Future<void> acceptRequest(Map<String, dynamic> request) async {
    final sessionId = request['sessionId'];
    final userId = request['userId'];

    // Update data
    DummyData.acceptJoinRequest(sessionId, userId);

    // Reload data
    await loadMatchesData();

    // Clear expanded state
    _expandedRequestId = null;

    // Clean up animation controller
    unregisterCardController(request['id']);

    notifyListeners();
  }

  // Reject a pending request
  Future<void> rejectRequest(Map<String, dynamic> request) async {
    final sessionId = request['sessionId'];
    final userId = request['userId'];

    // Update data
    DummyData.rejectJoinRequest(sessionId, userId);

    // Reload data
    await loadMatchesData();

    // Clear expanded state
    _expandedRequestId = null;

    // Clean up animation controller
    unregisterCardController(request['id']);

    notifyListeners();
  }

  // Open message screen (placeholder)
  void openMessageScreen(Map<String, dynamic> user) {
    // TODO: Navigate to message screen
    // This would be implemented when the messaging feature is added
  }

  // Get mode-specific empty state data
  Map<String, dynamic> get emptyStateData {
    if (_isActiveMode) {
      return {
        'icon': Icons.chat_bubble_outline,
        'title': 'No Active Sessions',
        'description': 'You don\'t have any active meal sessions yet.\nAccept join requests to start chatting with participants!',
        'actionText': 'View Requests',
        'showAction': _pendingRequests.isNotEmpty,
      };
    } else {
      return {
        'icon': Icons.notifications_none,
        'title': 'No Pending Requests',
        'description': 'No one has requested to join your sessions yet.\nCreate more sessions to get join requests!',
        'actionText': 'Create Session',
        'showAction': true,
      };
    }
  }

  // Handle empty state action
  void handleEmptyStateAction() {
    if (_isActiveMode) {
      // Switch to pending requests if there are any
      if (_pendingRequests.isNotEmpty) {
        setMode(false);
      }
    } else {
      // Navigate to discover screen to create sessions
      // This would be handled by the parent widget
    }
  }

  @override
  void dispose() {
    // Dispose all animation controllers
    for (final controller in _cardControllers.values) {
      controller.dispose();
    }
    _cardControllers.clear();
    _cardAnimations.clear();
    super.dispose();
  }
}