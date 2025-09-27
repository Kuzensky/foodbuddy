import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class ActiveSessionCard extends StatefulWidget {
  final Map<String, dynamic> request;
  final bool isExpanded;
  final Animation<double>? animation;
  final VoidCallback onTap;
  final VoidCallback onMessage;

  const ActiveSessionCard({
    super.key,
    required this.request,
    required this.isExpanded,
    this.animation,
    required this.onTap,
    required this.onMessage,
  });

  @override
  State<ActiveSessionCard> createState() => _ActiveSessionCardState();
}

class _ActiveSessionCardState extends State<ActiveSessionCard> {
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

  String _formatSessionTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      return 'Started ${_formatDateTime(isoString)}';
    } else if (difference.inHours < 24) {
      return 'In ${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return 'In ${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.request['user'];
    final session = widget.request['session'];
    final restaurant = DummyData.getRestaurantById(session['restaurantId']);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isExpanded ? Colors.black87 : Colors.grey.shade200,
            width: widget.isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isExpanded ? Colors.black.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
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
                  // Header with user info and session status
                  Row(
                    children: [
                      // User avatar with online indicator
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: user['profilePicture'] != null
                                  ? NetworkImage(user['profilePicture']) as ImageProvider
                                  : null,
                              child: user['profilePicture'] == null
                                  ? Text(
                                      _getInitials(user['name']),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          // Online indicator
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade600,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // User info and session details
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
                                      color: Colors.black87,
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
                            Text(
                              session['title'],
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatSessionTime(session['scheduledTime']),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Quick message button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: widget.onMessage,
                          icon: Icon(
                            Icons.message,
                            color: Colors.black87,
                            size: 20,
                          ),
                          tooltip: 'Send message',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Restaurant info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        // Restaurant image or icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: restaurant?['imageUrl'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    restaurant!['imageUrl'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.restaurant,
                                  color: Colors.grey.shade600,
                                  size: 24,
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Restaurant details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant?['name'] ?? 'Restaurant',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${restaurant?['rating'] ?? '4.5'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w500,
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
                                    restaurant?['cuisine'] ?? 'Restaurant',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Participant count
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${session['currentParticipants']}/${session['maxParticipants']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
                child: _buildExpandedContent(user, session, restaurant),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    Map<String, dynamic> user,
    Map<String, dynamic> session,
    Map<String, dynamic>? restaurant,
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
          // Session timeline
          _buildInfoSection('Session Timeline', [
            _buildTimelineItem(
              Icons.schedule,
              'Scheduled',
              _formatSessionTime(session['scheduledTime']),
              Colors.grey.shade600,
            ),
            _buildTimelineItem(
              Icons.check_circle,
              'Accepted',
              _formatDateTime(widget.request['acceptedAt']),
              Colors.green.shade600,
            ),
          ]),
          const SizedBox(height: 20),
          // Participant info
          _buildInfoSection('About ${user['name']}', [
            _buildInfoRow(Icons.star, '${user['rating']} rating', Colors.grey.shade600),
            _buildInfoRow(Icons.location_on, user['location'] ?? 'Location not set', Colors.grey.shade600),
            _buildInfoRow(Icons.cake, 'Age ${user['age']}', Colors.grey.shade600),
          ]),
          const SizedBox(height: 16),
          // Bio
          if (user['bio'] != null && user['bio'].toString().isNotEmpty) ...[
            Text(
              'Bio',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user['bio'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
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
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onMessage,
              icon: const Icon(Icons.message, size: 18),
              label: const Text('Start Conversation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
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
    );
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

  Widget _buildTimelineItem(IconData icon, String title, String time, Color color) {
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
                  time,
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