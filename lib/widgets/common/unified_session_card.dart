import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

enum SessionCardType { discover, create, matches }

enum _ModernButtonStyle { filled, outlined, danger }

class UnifiedSessionCard extends StatefulWidget {
  final Map<String, dynamic> session;
  final SessionCardType cardType;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final VoidCallback? onPass;
  final VoidCallback? onCancel;
  final VoidCallback? onShare;
  final VoidCallback? onInvite;
  final VoidCallback? onMessage;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final int animationIndex;
  final bool isPendingRequest;
  final bool isCompact;

  const UnifiedSessionCard({
    super.key,
    required this.session,
    required this.cardType,
    this.onTap,
    this.onJoin,
    this.onPass,
    this.onCancel,
    this.onShare,
    this.onInvite,
    this.onMessage,
    this.onAccept,
    this.onReject,
    this.animationIndex = 0,
    this.isPendingRequest = false,
    this.isCompact = false,
  });

  @override
  State<UnifiedSessionCard> createState() => _UnifiedSessionCardState();
}

class _UnifiedSessionCardState extends State<UnifiedSessionCard> with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isDropdownExpanded = false;
  late AnimationController _animationController;
  late AnimationController _dropdownController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _dropdownAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _dropdownController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _dropdownAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _dropdownController,
      curve: Curves.easeInOutCubic,
    ));

    // Stagger animation based on index
    Future.delayed(Duration(milliseconds: widget.animationIndex * 150), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dropdownController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownExpanded = !_isDropdownExpanded;
    });
    if (_isDropdownExpanded) {
      _dropdownController.forward();
    } else {
      _dropdownController.reverse();
    }
  }

  String _formatTime(String? dateTime) {
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

  String _formatTimeShort(String? dateTime) {
    if (dateTime == null) return 'TBD';
    try {
      final dt = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = dt.difference(now);

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

  Widget _buildModernActions() {
    switch (widget.cardType) {
      case SessionCardType.discover:
        return Row(
          children: [
            Expanded(
              child: _ModernButton(
                onPressed: widget.onPass,
                icon: Icons.close,
                label: 'Pass',
                style: _ModernButtonStyle.outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _ModernButton(
                onPressed: widget.onJoin,
                icon: Icons.add,
                label: 'Join Session',
                style: _ModernButtonStyle.filled,
              ),
            ),
          ],
        );

      case SessionCardType.create:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _ModernButton(
                    onPressed: widget.onCancel,
                    icon: Icons.cancel_outlined,
                    label: 'Cancel Session',
                    style: _ModernButtonStyle.danger,
                  ),
                ),
                const SizedBox(width: 8),
                _ModernIconButton(
                  onPressed: widget.onShare,
                  icon: Icons.share,
                  tooltip: 'Share',
                ),
                const SizedBox(width: 8),
                _ModernIconButton(
                  onPressed: widget.onInvite,
                  icon: Icons.person_add_outlined,
                  tooltip: 'Invite',
                ),
              ],
            ),
          ],
        );

      case SessionCardType.matches:
        if (widget.isPendingRequest) {
          return Row(
            children: [
              Expanded(
                child: _ModernButton(
                  onPressed: widget.onReject,
                  icon: Icons.close,
                  label: 'Decline',
                  style: _ModernButtonStyle.outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _ModernButton(
                  onPressed: widget.onAccept,
                  icon: Icons.check,
                  label: 'Accept',
                  style: _ModernButtonStyle.filled,
                ),
              ),
            ],
          );
        } else {
          return _ModernButton(
            onPressed: widget.onMessage,
            icon: Icons.message,
            label: 'Send Message',
            style: _ModernButtonStyle.filled,
            fullWidth: true,
          );
        }
    }
  }

  Widget _buildModernUserProfile(Map<String, dynamic>? creator) {
    String initials = 'U';
    if (creator != null && creator['name'] != null) {
      final name = creator['name'].toString();
      final names = name.split(' ');
      if (names.length > 1) {
        initials = '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else if (name.isNotEmpty) {
        initials = name[0].toUpperCase();
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade600,
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  creator?['name'] ?? 'User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Session Host',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStunningRestaurantImage(Map<String, dynamic>? restaurant) {
    String imageUrl = _getCuisineImageUrl(restaurant?['cuisine']?.toString().toLowerCase() ?? 'restaurant');

    return Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Main Image
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackGradient(restaurant?['cuisine']?.toString().toLowerCase());
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildFallbackGradient(restaurant?['cuisine']?.toString().toLowerCase());
                },
              ),
            ),
            // Gradient Overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Cuisine Badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  restaurant?['cuisine']?.toString().toUpperCase() ?? 'RESTAURANT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            // Time Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimeShort(widget.session['scheduledTime']),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _buildFallbackGradient(String? cuisine) {
    List<Color> gradientColors;
    IconData icon;

    switch (cuisine) {
      case 'italian':
        gradientColors = [Colors.red.shade300, Colors.green.shade400];
        icon = Icons.local_pizza;
        break;
      case 'japanese':
      case 'sushi':
        gradientColors = [Colors.pink.shade200, Colors.orange.shade300];
        icon = Icons.restaurant;
        break;
      case 'mexican':
        gradientColors = [Colors.orange.shade300, Colors.red.shade400];
        icon = Icons.local_dining;
        break;
      case 'korean':
        gradientColors = [Colors.red.shade400, Colors.orange.shade300];
        icon = Icons.local_fire_department;
        break;
      case 'vegan':
        gradientColors = [Colors.green.shade300, Colors.lime.shade400];
        icon = Icons.eco;
        break;
      default:
        gradientColors = [Colors.grey.shade300, Colors.grey.shade500];
        icon = Icons.restaurant;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo(Map<String, dynamic>? restaurant) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant?['name'] ?? 'Restaurant',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.session['title'] ?? 'Meal Session',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${widget.session['participants']?.length ?? 0}/${widget.session['maxParticipants'] ?? 4}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Rating and Details Row
          Row(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    restaurant?['rating']?.toString() ?? '4.5',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    restaurant?['priceRange'] ?? '₱₱',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(widget.session['scheduledTime']),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = DummyData.getRestaurantById(widget.session['restaurantId'] ?? '');
    final creator = DummyData.getUserById(widget.session['hostUserId'] ?? '');

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.isCompact ? _buildCompactCard(creator, restaurant) : _buildFullCard(creator, restaurant),
      ),
    );
  }

  Widget _buildFullCard(Map<String, dynamic>? creator, Map<String, dynamic>? restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          iconColor: Colors.transparent,
          collapsedIconColor: Colors.transparent,
          textColor: Colors.black87,
          collapsedTextColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Section
              _buildModernUserProfile(creator),

              // Restaurant Image (Full Width)
              _buildStunningRestaurantImage(restaurant),

              // Restaurant Info
              _buildRestaurantInfo(restaurant),
            ],
          ),
          children: [
            // Expanded Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.session['description'] ?? 'Join us for a great meal!',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
            _buildModernActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCard(Map<String, dynamic>? creator, Map<String, dynamic>? restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Profile + Name + Dropdown Button
          Row(
            children: [
              _buildCompactUserAvatar(creator),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  creator?['name'] ?? 'User',
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
                onTap: _toggleDropdown,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isDropdownExpanded ? Colors.black87 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: AnimatedRotation(
                    turns: _isDropdownExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: _isDropdownExpanded ? Colors.white : Colors.grey.shade600,
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
                '${widget.session['participants']?.length ?? 0}/${widget.session['maxParticipants'] ?? 4} people',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                _formatTimeShort(widget.session['scheduledTime']),
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
            height: _isDropdownExpanded ? null : 0,
            child: _isDropdownExpanded
                ? IntrinsicHeight(
                    child: _buildExpandableContent(),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 12),

          // Context-aware buttons based on card type
          if (!_isDropdownExpanded)
            _buildContextualButtons()
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

  Widget _buildPracticalHeader(Map<String, dynamic>? creator, Map<String, dynamic>? restaurant) {
    return Row(
      children: [
        _buildCompactUserAvatar(creator),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                creator?['name'] ?? 'User',
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
                    '${widget.session['participants']?.length ?? 0}/${widget.session['maxParticipants'] ?? 4} people',
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
                    _formatTimeShort(widget.session['scheduledTime']),
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
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isDropdownExpanded ? Colors.black87 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AnimatedRotation(
              turns: _isDropdownExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: _isDropdownExpanded ? Colors.white : Colors.grey.shade600,
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
          _buildPreferenceRow(Icons.group, 'Group Size', '${widget.session['participants']?.length ?? 0}/${widget.session['maxParticipants'] ?? 4} people'),
          _buildPreferenceRow(Icons.schedule, 'Time', _formatTimeShort(widget.session['scheduledTime'])),
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

  Widget _buildContextualButtons() {
    switch (widget.cardType) {
      case SessionCardType.matches:
        // Check if it's active session or pending request
        if (widget.isPendingRequest == true) {
          // Pending Request: Accept & Reject
          return _buildPendingRequestButtons();
        } else {
          // Active Session: Message (full width)
          return _buildMessageButton();
        }

      case SessionCardType.create:
        // My Sessions: Cancel & Invite
        return _buildMySessionButtons();

      case SessionCardType.discover:
      default:
        // Discover: Pass & Join (handled by ModernSessionCard)
        return _buildDiscoverButtons();
    }
  }

  Widget _buildMessageButton() {
    return Container(
      width: double.infinity,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: widget.onMessage,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.message, size: 18),
        label: const Text(
          'Message',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPendingRequestButtons() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          // Reject Button
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onReject,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Reject',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Accept Button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: widget.onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Accept',
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

  Widget _buildMySessionButtons() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          // Cancel Session Button
          Expanded(
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Invite Friends Button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: widget.onInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text(
                'Invite',
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

  Widget _buildCompactUserAvatar(Map<String, dynamic>? creator) {
    String initials = 'U';
    if (creator != null && creator['name'] != null) {
      final name = creator['name'].toString();
      final names = name.split(' ');
      if (names.length > 1) {
        initials = '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else if (name.isNotEmpty) {
        initials = name[0].toUpperCase();
      }
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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

  Widget _buildCompactActions() {
    switch (widget.cardType) {
      case SessionCardType.discover:
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

      case SessionCardType.create:
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
            const SizedBox(width: 6),
            SizedBox(
              width: 32,
              child: ElevatedButton(
                onPressed: widget.onInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade700,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.person_add, size: 14),
              ),
            ),
          ],
        );

      case SessionCardType.matches:
        if (widget.isPendingRequest) {
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Decline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: widget.onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          );
        } else {
          return ElevatedButton(
            onPressed: widget.onMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Message', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          );
        }
    }
  }
}

// Modern Button Component
class _ModernButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final _ModernButtonStyle style;
  final bool fullWidth;

  const _ModernButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.style,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;

    switch (style) {
      case _ModernButtonStyle.filled:
        backgroundColor = Colors.black87;
        foregroundColor = Colors.white;
        borderColor = Colors.black87;
        break;
      case _ModernButtonStyle.outlined:
        backgroundColor = Colors.white;
        foregroundColor = Colors.grey.shade700;
        borderColor = Colors.grey.shade300;
        break;
      case _ModernButtonStyle.danger:
        backgroundColor = Colors.white;
        foregroundColor = Colors.red.shade600;
        borderColor = Colors.red.shade300;
        break;
    }

    Widget button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: style == _ModernButtonStyle.filled ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1.5),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

// Modern Icon Button Component
class _ModernIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String tooltip;

  const _ModernIconButton({
    required this.onPressed,
    required this.icon,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 20,
            color: Colors.grey.shade700,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}