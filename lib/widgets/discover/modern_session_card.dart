import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../data/dummy_data.dart';

class ModernSessionCard extends StatefulWidget {
  final Map<String, dynamic> session;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onPass;
  final bool isCompact;
  final int animationIndex;

  const ModernSessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.onJoin,
    this.onPass,
    this.isCompact = false,
    this.animationIndex = 0,
  });

  @override
  State<ModernSessionCard> createState() => _ModernSessionCardState();
}

class _ModernSessionCardState extends State<ModernSessionCard>
    with TickerProviderStateMixin {

  late AnimationController _hoverController;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final host = DummyData.getUserById(widget.session['hostUserId']);
    final restaurant = DummyData.getRestaurantById(widget.session['restaurantId']);

    return AnimationConfiguration.staggeredList(
      position: widget.animationIndex,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: AnimatedBuilder(
            animation: Listenable.merge([_hoverController, _pressController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: widget.isCompact ? 12 : 16,
                    left: 20,
                    right: 20,
                  ),
                  child: Material(
                    elevation: _elevationAnimation.value,
                    borderRadius: BorderRadius.circular(20),
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    child: GestureDetector(
                      onTap: widget.onTap,
                      onTapDown: _onTapDown,
                      onTapUp: _onTapUp,
                      onTapCancel: _onTapCancel,
                      child: MouseRegion(
                        onEnter: (_) {
                          setState(() => _isHovered = true);
                          _hoverController.forward();
                        },
                        onExit: (_) {
                          setState(() => _isHovered = false);
                          _hoverController.reverse();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade100,
                              width: 1,
                            ),
                          ),
                          child: widget.isCompact
                              ? _buildCompactContent(host, restaurant)
                              : _buildFullContent(host, restaurant),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompactContent(
    Map<String, dynamic>? host,
    Map<String, dynamic>? restaurant,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              _buildHostAvatar(host),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.session['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      host?['name'] ?? 'Host',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSessionStatus(),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            widget.session['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // Quick info
          Row(
            children: [
              _buildQuickInfo(
                Icons.restaurant,
                restaurant?['name'] ?? 'Restaurant',
              ),
              const SizedBox(width: 16),
              _buildQuickInfo(
                Icons.people,
                '${widget.session['currentParticipants']}/${widget.session['maxParticipants']}',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          _buildCompactActions(),
        ],
      ),
    );
  }

  Widget _buildFullContent(
    Map<String, dynamic>? host,
    Map<String, dynamic>? restaurant,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero image
        if (restaurant?['imageUrl'] != null)
          _buildRestaurantImage(restaurant!),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Host and title section
              _buildHostSection(host),

              const SizedBox(height: 16),

              // Title and description
              Text(
                widget.session['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.session['description'],
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // Restaurant info
              _buildRestaurantInfo(restaurant),

              const SizedBox(height: 16),

              // Session details
              _buildSessionDetails(),

              const SizedBox(height: 20),

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHostAvatar(Map<String, dynamic>? host) {
    return Stack(
      children: [
        CircleAvatar(
          radius: widget.isCompact ? 18 : 24,
          backgroundColor: Colors.grey.shade100,
          child: Text(
            host != null ? _getInitials(host['name']) : 'H',
            style: TextStyle(
              fontSize: widget.isCompact ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        if (host?['isVerified'] == true)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: widget.isCompact ? 14 : 16,
              height: widget.isCompact ? 14 : 16,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: widget.isCompact ? 8 : 10,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSessionStatus() {
    final spotsLeft = widget.session['maxParticipants'] - widget.session['currentParticipants'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: spotsLeft > 0 ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: spotsLeft > 0 ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Text(
        spotsLeft > 0 ? '$spotsLeft spots' : 'Almost full',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: spotsLeft > 0 ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onPass,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Pass', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: widget.onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Join', style: TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantImage(Map<String, dynamic> restaurant) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        image: DecorationImage(
          image: NetworkImage(restaurant['imageUrl']),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${restaurant['cuisine']} • ${restaurant['priceRange']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHostSection(Map<String, dynamic>? host) {
    return Row(
      children: [
        _buildHostAvatar(host),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                host?['name'] ?? 'Host',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (host != null)
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${host['rating']} rating',
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
        _buildSessionStatus(),
      ],
    );
  }

  Widget _buildRestaurantInfo(Map<String, dynamic>? restaurant) {
    if (restaurant == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.restaurant, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${restaurant['cuisine']} • ${restaurant['address']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber.shade600),
              const SizedBox(width: 2),
              Text(
                restaurant['rating'].toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetails() {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem(
            Icons.schedule,
            _formatDateTime(widget.session['scheduledTime']),
          ),
        ),
        Expanded(
          child: _buildDetailItem(
            Icons.people,
            '${widget.session['currentParticipants']}/${widget.session['maxParticipants']} people',
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onPass,
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Pass'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: widget.onJoin,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Join Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
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
}

// Grid layout version for different view modes
class SessionCardGrid extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final Function(Map<String, dynamic>) onSessionTap;
  final Function(Map<String, dynamic>) onJoinSession;
  final Function(Map<String, dynamic>) onPassSession;

  const SessionCardGrid({
    super.key,
    required this.sessions,
    required this.onSessionTap,
    required this.onJoinSession,
    required this.onPassSession,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          return ModernSessionCard(
            session: sessions[index],
            isCompact: true,
            animationIndex: index,
            onTap: () => onSessionTap(sessions[index]),
            onJoin: () => onJoinSession(sessions[index]),
            onPass: () => onPassSession(sessions[index]),
          );
        },
      ),
    );
  }
}