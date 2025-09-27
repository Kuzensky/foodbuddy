import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../data/dummy_data.dart';

class ModernSessionCard extends StatefulWidget {
  final Map<String, dynamic> session;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onPass;
  final VoidCallback? onCancel;
  final VoidCallback? onShare;
  final VoidCallback? onInvite;
  final bool isCompact;
  final int animationIndex;
  final bool isMySession; // New parameter to determine button layout

  const ModernSessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.onJoin,
    this.onPass,
    this.onCancel,
    this.onShare,
    this.onInvite,
    this.isCompact = false,
    this.animationIndex = 0,
    this.isMySession = false, // Default to false (discover mode)
  });

  @override
  State<ModernSessionCard> createState() => _ModernSessionCardState();
}

class _ModernSessionCardState extends State<ModernSessionCard>
    with TickerProviderStateMixin {

  late AnimationController _hoverController;
  late AnimationController _pressController;
  late AnimationController _expandController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _expandAnimation;

  bool _isHovered = false;
  bool _isExpanded = false;

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

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
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
                    bottom: widget.isCompact ? 16 : 16,
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Profile + Name + Dropdown Button
          Row(
            children: [
              _buildCompactHostAvatar(host),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  host?['name'] ?? 'Host',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _toggleExpanded,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isExpanded ? Colors.black87 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: _isExpanded ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Restaurant Image
          Container(
            height: 100,
            width: double.infinity,
            child: _buildCompactRestaurantImage(restaurant),
          ),
          const SizedBox(height: 12),

          // Restaurant Name
          Text(
            restaurant?['name'] ?? 'Restaurant',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Session Info Row
          Row(
            children: [
              Icon(Icons.group, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${widget.session['currentParticipants']}/${widget.session['maxParticipants']} people',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                _formatTimeCompact(widget.session['scheduledTime']),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          // Expandable Details Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? IntrinsicHeight(
                    child: _buildExpandableContent(),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 12),

          // Always visible: Action buttons (Pass & Join for Discover)
          if (!_isExpanded)
            _buildDiscoverButtons()
          else
            // Show action buttons when expanded
            SizedBox(
              height: 36,
              child: _buildCompactActions(),
            ),
        ],
      ),
    );
  }

  Widget _buildPracticalHeader(Map<String, dynamic>? host, Map<String, dynamic>? restaurant) {
    return Row(
      children: [
        _buildCompactHostAvatar(host),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                host?['name'] ?? 'Host',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Text(
                    '${widget.session['currentParticipants']}/${widget.session['maxParticipants']} people',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimeCompact(widget.session['scheduledTime']),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Interactive expand/collapse button
        GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isExpanded ? Colors.black87 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: _isExpanded ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(Map<String, dynamic>? restaurant) {
    return Text(
      restaurant?['name'] ?? 'Restaurant',
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildExpandableContent() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session Preferences',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildPreferenceRow(Icons.restaurant_menu, 'Cuisine', widget.session['cuisine'] ?? 'Any'),
          _buildPreferenceRow(Icons.attach_money, 'Budget', widget.session['priceRange'] ?? '\$\$'),
          _buildPreferenceRow(Icons.group, 'Group Size', '${widget.session['currentParticipants']}/${widget.session['maxParticipants']} people'),
          _buildPreferenceRow(Icons.schedule, 'Time', _formatTimeCompact(widget.session['scheduledTime'])),
          if (widget.session['ageRange'] != null)
            _buildPreferenceRow(Icons.cake, 'Age Range', widget.session['ageRange']),
          if (widget.session['notes'] != null)
            _buildPreferenceRow(Icons.notes, 'Notes', widget.session['notes']),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverButtons() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          // Pass Button
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onPass,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Pass',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Join Button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: widget.onJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Join',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
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

  Widget _buildCompactHostAvatar(Map<String, dynamic>? host) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey.shade200,
      child: Text(
        host != null ? _getInitials(host['name']) : 'H',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCompactRestaurantImage(Map<String, dynamic>? restaurant) {
    String imageUrl = _getCuisineImageUrl(restaurant?['cuisine']?.toString().toLowerCase() ?? 'restaurant');

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildCompactFallback(restaurant?['cuisine']?.toString().toLowerCase());
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildCompactFallback(restaurant?['cuisine']?.toString().toLowerCase());
          },
        ),
      ),
    );
  }

  String _getCuisineImageUrl(String cuisine) {
    // High-quality, larger restaurant images from Unsplash
    switch (cuisine) {
      case 'italian':
        return 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=1200&q=85'; // Pasta
      case 'japanese':
      case 'sushi':
        return 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=1200&q=85'; // Sushi
      case 'mexican':
        return 'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=1200&q=85'; // Tacos
      case 'chinese':
        return 'https://images.unsplash.com/photo-1526318896980-cf78c088247c?w=1200&q=85'; // Asian cuisine
      case 'korean':
        return 'https://images.unsplash.com/photo-1498654896293-37aacf113fd9?w=1200&q=85'; // Korean BBQ
      case 'thai':
        return 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=1200&q=85'; // Thai food
      case 'american':
        return 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=1200&q=85'; // Burger
      case 'french':
        return 'https://images.unsplash.com/photo-1514326640560-7d063ef2aed5?w=1200&q=85'; // Fine dining
      case 'vegan':
        return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=1200&q=85'; // Vegan bowl
      case 'desserts':
        return 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=1200&q=85'; // Desserts
      case 'indian':
        return 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=1200&q=85'; // Indian curry
      case 'mediterranean':
        return 'https://images.unsplash.com/photo-1544510808-5c58c2a5b9d4?w=1200&q=85'; // Mediterranean
      default:
        return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=1200&q=85'; // General restaurant
    }
  }

  Widget _buildCompactFallback(String? cuisine) {
    IconData icon;
    Color color;

    switch (cuisine) {
      case 'italian':
        icon = Icons.local_pizza;
        color = Colors.red.shade300;
        break;
      case 'japanese':
      case 'sushi':
        icon = Icons.restaurant;
        color = Colors.pink.shade300;
        break;
      case 'mexican':
        icon = Icons.local_dining;
        color = Colors.orange.shade300;
        break;
      case 'indian':
        icon = Icons.local_fire_department;
        color = Colors.orange.shade400;
        break;
      default:
        icon = Icons.restaurant;
        color = Colors.grey.shade400;
    }

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 32,
        ),
      ),
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
    if (widget.isMySession) {
      // My Sessions: Large Cancel button + Small Share button
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: widget.onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade600,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 6),
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 32,
            child: ElevatedButton(
              onPressed: widget.onShare,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(Icons.share, size: 14),
            ),
          ),
        ],
      );
    } else {
      // Discover: Pass + Join buttons
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onPass,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Pass', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: widget.onJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Join', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      );
    }
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
    if (widget.isMySession) {
      // My Sessions: Invite, Large Cancel button + Share button
      return Column(
        children: [
          // Invite button (full width)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onInvite,
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Invite Friends'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade600,
                side: BorderSide(color: Colors.blue.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Cancel + Share row
          Row(
            children: [
              Expanded(
                flex: 4,
                child: ElevatedButton.icon(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.cancel, size: 18),
                  label: const Text('Cancel Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  onPressed: widget.onShare,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade500,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.share, size: 20),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Discover: Pass + Join buttons
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

  String _formatTimeCompact(String? isoString) {
    if (isoString == null) return 'TBD';
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = dateTime.difference(now);

      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Now';
      }
    } catch (e) {
      return 'TBD';
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