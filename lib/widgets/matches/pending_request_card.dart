import 'package:flutter/material.dart';

class PendingRequestCard extends StatefulWidget {
  final Map<String, dynamic> request;
  final bool isExpanded;
  final Animation<double>? animation;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const PendingRequestCard({
    super.key,
    required this.request,
    required this.isExpanded,
    this.animation,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<PendingRequestCard> createState() => _PendingRequestCardState();
}

class _PendingRequestCardState extends State<PendingRequestCard> {
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

  int _calculateCompatibility(Map<String, dynamic> user) {
    // Simple compatibility calculation based on food preferences
    final userPrefs = user['foodPreferences'] as List? ?? [];
    // In a real app, this would compare with the current user's preferences
    // For now, we'll use a simple formula
    return (75 + (userPrefs.length * 3)).clamp(60, 95);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.request['user'];
    final session = widget.request['session'];
    final restaurant = {'name': 'Unknown Restaurant', 'cuisine': 'Unknown'};
    final compatibility = _calculateCompatibility(user);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isExpanded ? Colors.grey.shade200 : Colors.grey.shade200,
            width: widget.isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isExpanded ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              blurRadius: widget.isExpanded ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with user info and compatibility
                  Row(
                    children: [
                      // User avatar with request indicator
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
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
                          // Request indicator
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                if (user['isVerified'] == true) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${user['rating']} rating',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Age ${user['age']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Requested ${_formatDateTime(widget.request['requestedAt'])}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Compatibility score
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getCompatibilityColor(compatibility).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$compatibility%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getCompatibilityColor(compatibility),
                              ),
                            ),
                            Text(
                              'Match',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getCompatibilityColor(compatibility),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Session info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                restaurant?['name'] ?? 'Restaurant',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${session['currentParticipants']}/${session['maxParticipants']}',
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
                  ),
                  // Quick action buttons (when not expanded)
                  if (!widget.isExpanded) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onReject,
                            icon: const Icon(Icons.close, size: 16),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onAccept,
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Accept'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
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
                    ),
                  ],
                  // Expand indicator
                  const SizedBox(height: 12),
                  Center(
                    child: AnimatedRotation(
                      turns: widget.isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade400,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Expandable content
            if (widget.animation != null)
              SizeTransition(
                sizeFactor: widget.animation!,
                child: _buildExpandedContent(user, session, restaurant, compatibility),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCompatibilityColor(int compatibility) {
    if (compatibility >= 85) return Colors.grey.shade600;
    if (compatibility >= 70) return Colors.grey.shade600;
    return Colors.grey.shade600;
  }

  Widget _buildExpandedContent(
    Map<String, dynamic> user,
    Map<String, dynamic> session,
    Map<String, dynamic>? restaurant,
    int compatibility,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compatibility breakdown
          _buildInfoSection('Why ${user['name']} is a $compatibility% match', [
            _buildCompatibilityItem(
              Icons.restaurant_menu,
              'Food Preferences',
              _getCompatibilityText(compatibility, 'food'),
              _getCompatibilityColor(compatibility),
            ),
            _buildCompatibilityItem(
              Icons.schedule,
              'Availability',
              _getCompatibilityText(compatibility, 'time'),
              _getCompatibilityColor(compatibility),
            ),
            _buildCompatibilityItem(
              Icons.location_on,
              'Location',
              _getCompatibilityText(compatibility, 'location'),
              _getCompatibilityColor(compatibility),
            ),
          ]),
          const SizedBox(height: 20),
          // About user
          _buildInfoSection('About ${user['name']}', [
            _buildInfoRow(Icons.location_on, user['location'] ?? 'Location not set', Colors.grey.shade600),
            if (user['bio'] != null && user['bio'].toString().isNotEmpty)
              _buildInfoRow(Icons.info_outline, user['bio'], Colors.grey.shade600),
          ]),
          const SizedBox(height: 16),
          // Food preferences
          if (user['foodPreferences'] != null && (user['foodPreferences'] as List).isNotEmpty) ...[
            Text(
              'Food Preferences',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (user['foodPreferences'] as List).take(6).map<Widget>((pref) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    pref.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
          // Session details
          _buildInfoSection('Session Details', [
            _buildInfoRow(Icons.schedule, _formatDateTime(session['scheduledTime']), Colors.grey.shade600),
            if (restaurant != null)
              _buildInfoRow(Icons.restaurant_menu, '${restaurant['cuisine']} • ${restaurant['priceRange']}', Colors.grey.shade600),
          ]),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onReject,
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Decline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onAccept,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Accept Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCompatibilityText(int compatibility, String type) {
    switch (type) {
      case 'food':
        return compatibility >= 85 ? 'Great match' : compatibility >= 70 ? 'Good match' : 'Some overlap';
      case 'time':
        return compatibility >= 85 ? 'Perfect timing' : compatibility >= 70 ? 'Good timing' : 'Flexible timing';
      case 'location':
        return compatibility >= 85 ? 'Very close' : compatibility >= 70 ? 'Nearby' : 'Reasonable distance';
      default:
        return 'Compatible';
    }
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityItem(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}