import 'package:flutter/material.dart';
import '../data/dummy_data.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _acceptedRequests = [];
  bool _isLoading = true;
  String? _expandedRequestId;
  final Map<String, AnimationController> _cardControllers = {};
  final Map<String, Animation<double>> _cardAnimations = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _loadMatchesData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _cardControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMatchesData() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _pendingRequests = DummyData.getJoinRequestsForCurrentUser();
      _acceptedRequests = DummyData.getAcceptedJoinRequestsForCurrentUser();
      _isLoading = false;
    });

    _animationController.forward();
  }

  AnimationController _getCardController(String requestId) {
    if (!_cardControllers.containsKey(requestId)) {
      _cardControllers[requestId] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _cardAnimations[requestId] = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _cardControllers[requestId]!,
        curve: Curves.easeInOut,
      ));
    }
    return _cardControllers[requestId]!;
  }

  void _toggleCardExpansion(String requestId) {
    final controller = _getCardController(requestId);

    setState(() {
      if (_expandedRequestId == requestId) {
        _expandedRequestId = null;
        controller.reverse();
      } else {
        // Collapse any currently expanded card
        if (_expandedRequestId != null) {
          _getCardController(_expandedRequestId!).reverse();
        }
        _expandedRequestId = requestId;
        controller.forward();
      }
    });
  }

  void _acceptRequest(Map<String, dynamic> request) async {
    final sessionId = request['sessionId'];
    final userId = request['userId'];

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

    // Update data
    DummyData.acceptJoinRequest(sessionId, userId);

    // Reload data
    setState(() {
      _pendingRequests = DummyData.getJoinRequestsForCurrentUser();
      _acceptedRequests = DummyData.getAcceptedJoinRequestsForCurrentUser();
      _expandedRequestId = null;
    });

    // Dispose of animation controller for this request
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
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _rejectRequest(Map<String, dynamic> request) async {
    final sessionId = request['sessionId'];
    final userId = request['userId'];

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

    // Update data
    DummyData.rejectJoinRequest(sessionId, userId);

    // Reload data
    setState(() {
      _pendingRequests = DummyData.getJoinRequestsForCurrentUser();
      _expandedRequestId = null;
    });

    // Dispose of animation controller for this request
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
          backgroundColor: Colors.red.shade400,
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
    // TODO: Implement navigation to messaging screen
    // Navigator.pushNamed(context, '/message', arguments: {'userId': user['id']});
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
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
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
          'Matches',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _buildContent(),
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
            'Loading your matches...',
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
      opacity: _fadeInAnimation,
      child: RefreshIndicator(
        onRefresh: _loadMatchesData,
        child: CustomScrollView(
          slivers: [
            if (_pendingRequests.isNotEmpty) ...[
              _buildSectionHeader('Pending Requests', _pendingRequests.length),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final request = _pendingRequests[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: index == _pendingRequests.length - 1 ? 32 : 12,
                      ),
                      child: _buildUserCard(request, isPending: true),
                    );
                  },
                  childCount: _pendingRequests.length,
                ),
              ),
            ],
            if (_acceptedRequests.isNotEmpty) ...[
              _buildSectionHeader('Active Sessions', _acceptedRequests.length),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final request = _acceptedRequests[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: index == _acceptedRequests.length - 1 ? 32 : 12,
                      ),
                      child: _buildUserCard(request, isPending: false),
                    );
                  },
                  childCount: _acceptedRequests.length,
                ),
              ),
            ],
            if (_pendingRequests.isEmpty && _acceptedRequests.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(),
              ),
            // Add some bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
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
    );
  }

  Widget _buildUserCard(Map<String, dynamic> request, {required bool isPending}) {
    final user = request['user'];
    final session = request['session'];
    final restaurant = DummyData.getRestaurantById(session['restaurantId']);
    final isExpanded = _expandedRequestId == request['id'];
    final cardAnimation = _cardAnimations[request['id']];

    return GestureDetector(
      onTap: () => _toggleCardExpansion(request['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPending
                ? Colors.orange.shade200
                : Colors.green.shade200,
            width: 1.5,
          ),
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
              child: Row(
                children: [
                  // User avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPending
                            ? Colors.orange.shade300
                            : Colors.green.shade300,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: user['profilePicture'] != null
                          ? NetworkImage(user['profilePicture']) as ImageProvider
                          : null,
                      child: user['profilePicture'] == null
                          ? Text(
                              _getInitials(user['name']),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            if (user['isVerified'] == true) ...[
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
                                  size: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session['title'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                restaurant?['name'] ?? 'Restaurant',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              isPending
                                  ? _formatDateTime(request['requestedAt'])
                                  : _formatDateTime(request['acceptedAt']),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status indicator and expand arrow
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPending
                              ? Colors.orange.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isPending ? 'PENDING' : 'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isPending
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
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
                ],
              ),
            ),
            // Expandable content
            if (cardAnimation != null)
              SizeTransition(
                sizeFactor: cardAnimation,
                child: _buildExpandedContent(request, user, session, restaurant, isPending),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    Map<String, dynamic> request,
    Map<String, dynamic> user,
    Map<String, dynamic> session,
    Map<String, dynamic>? restaurant,
    bool isPending,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info section
          _buildInfoSection('About ${user['name']}', [
            _buildInfoRow(Icons.star, '${user['rating']} rating', Colors.amber),
            _buildInfoRow(Icons.location_on, user['location'] ?? 'Location not set', Colors.grey.shade600),
            _buildInfoRow(Icons.cake, 'Age ${user['age']}', Colors.grey.shade600),
          ]),
          const SizedBox(height: 16),
          // Bio
          if (user['bio'] != null && user['bio'].toString().isNotEmpty) ...[
            Text(
              'Bio',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user['bio'],
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
          ],
          // Food preferences
          if (user['foodPreferences'] != null && (user['foodPreferences'] as List).isNotEmpty) ...[
            Text(
              'Food Preferences',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: (user['foodPreferences'] as List).take(4).map<Widget>((pref) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    pref.toString(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          // Session details
          _buildInfoSection('Session Details', [
            _buildInfoRow(Icons.schedule, _formatDateTime(session['scheduledTime']), Colors.grey.shade600),
            _buildInfoRow(Icons.people, '${session['currentParticipants']}/${session['maxParticipants']} people', Colors.grey.shade600),
            if (restaurant != null)
              _buildInfoRow(Icons.restaurant_menu, '${restaurant['cuisine']} • ${restaurant['priceRange']}', Colors.grey.shade600),
          ]),
          const SizedBox(height: 20),
          // Action buttons
          if (isPending) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectRequest(request),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade600,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptRequest(request),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
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
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMessageScreen(user),
                icon: const Icon(Icons.message, size: 18),
                label: const Text('Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade700,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
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

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
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
              Icons.people_outline,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Matches Yet',
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
              'Create meal sessions to connect with other food lovers!\nYour join requests and accepted participants will appear here.',
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
              onPressed: () {
                // Navigate to discover screen to create sessions
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigate to Discover to create sessions!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
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
}