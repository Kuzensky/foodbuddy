import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/database_provider.dart';

class UserProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isFollowing = false;
  bool _isLoading = false;
  bool _areMutualFollows = false;
  int _pendingMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
    _checkMutualFollowStatus();
    _loadPendingMessageCount();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    await databaseProvider.loadFeedPosts();
  }

  Future<void> _checkFollowStatus() async {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final isFollowing = await databaseProvider.isFollowing(widget.user['id']);
    if (mounted) {
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  Future<void> _checkMutualFollowStatus() async {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final areMutual = await databaseProvider.areMutualFollows(widget.user['id']);
    if (mounted) {
      setState(() {
        _areMutualFollows = areMutual;
      });
    }
  }

  Future<void> _loadPendingMessageCount() async {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final count = await databaseProvider.getPendingMessageCount(widget.user['id']);
    if (mounted) {
      setState(() {
        _pendingMessageCount = count;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

      if (_isFollowing) {
        await databaseProvider.unfollowUser(widget.user['id']);
      } else {
        await databaseProvider.followUser(widget.user['id']);
      }

      setState(() {
        _isFollowing = !_isFollowing;
      });

      await _checkMutualFollowStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Message ${widget.user['name'] ?? 'User'}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_areMutualFollows)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will be a pending message until you follow each other',
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 3,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (messageController.text.trim().isEmpty) return;

              try {
                final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
                await databaseProvider.sendMessage(
                  widget.user['id'],
                  messageController.text.trim(),
                  isPending: !_areMutualFollows,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_areMutualFollows
                        ? 'Message sent!'
                        : 'Pending message sent!'),
                    ),
                  );
                  await _loadPendingMessageCount();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error sending message: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text(
              'Send',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildModernStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildModernRatingColumn(String rating) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rating,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 16,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Rating',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 32,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.user['name'] ?? 'User';
    final userInitials = _getInitials(userName);
    final rating = (widget.user['rating'] ?? 0.0).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          userName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Info Section - matching profile_screen.dart design
              _buildProfileInfo(userName, userInitials, rating),

              const SizedBox(height: 24),

              // Bio Section (if available)
              if (widget.user['bio'] != null && widget.user['bio'].toString().isNotEmpty)
                _buildBioSection(),

              if (widget.user['bio'] != null && widget.user['bio'].toString().isNotEmpty)
                const SizedBox(height: 20),

              // Food Preference Tags Section (if available)
              if (widget.user['foodPreferences'] != null)
                _buildFoodTagsSection(),

              if (widget.user['foodPreferences'] != null)
                const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),

              // Posts Section
              const SizedBox(height: 32),
              _buildPostsSection(),

              // Pending Messages Banner
              if (_pendingMessageCount > 0 && !_areMutualFollows) ...[
                const SizedBox(height: 24),
                _buildPendingMessagesBanner(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Modern Profile Info Section - matching profile_screen.dart design
  Widget _buildProfileInfo(String userName, String userInitials, String rating) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        children: [
          // Profile Picture Section - Centered at top
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  backgroundImage: widget.user['profilePicture'] != null
                      ? NetworkImage(widget.user['profilePicture']) as ImageProvider
                      : null,
                  child: widget.user['profilePicture'] == null
                      ? Text(
                          userInitials,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              // Name with verification badge - centered
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (widget.user['isVerified'] == true) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ],
              ),
              // Email below name
              if (widget.user['email'] != null && widget.user['email'].toString().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.user['email'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 32),

          // Stats Section - Clean horizontal layout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FutureBuilder<Map<String, int>>(
              future: Provider.of<DatabaseProvider>(context, listen: false)
                  .getFollowStats(userId: widget.user['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildModernStatColumn('...', 'Followers'),
                      _buildStatDivider(),
                      _buildModernStatColumn('...', 'Following'),
                      _buildStatDivider(),
                      _buildModernRatingColumn(rating),
                    ],
                  );
                }

                final stats = snapshot.data ?? {'followersCount': 0, 'followingCount': 0};
                final followersCount = _formatCount(stats['followersCount'] ?? 0);
                final followingCount = _formatCount(stats['followingCount'] ?? 0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildModernStatColumn(followersCount, 'Followers'),
                    _buildStatDivider(),
                    _buildModernStatColumn(followingCount, 'Following'),
                    _buildStatDivider(),
                    _buildModernRatingColumn(rating),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Bio Section - matching profile_screen.dart design
  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            widget.user['bio'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // Food Preference Tags Section - matching profile_screen.dart design
  Widget _buildFoodTagsSection() {
    final foodPreferences = widget.user['foodPreferences'] as List<dynamic>? ?? [];
    if (foodPreferences.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Preferences',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: foodPreferences.map((tag) => _buildTag(tag.toString())).toList(),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Action Buttons - redesigned to match app aesthetic
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: _isFollowing ? Colors.grey.shade100 : Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: _isFollowing ? Border.all(color: Colors.grey.shade300) : null,
            ),
            child: TextButton(
              onPressed: _isLoading ? null : _toggleFollow,
              child: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isFollowing ? Colors.grey.shade600 : Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      _isFollowing ? 'Unfollow' : 'Follow',
                      style: TextStyle(
                        fontSize: 16,
                        color: _isFollowing ? Colors.black87 : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: _sendMessage,
              child: const Text(
                'Message',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Pending Messages Banner - redesigned with cleaner styling
  Widget _buildPendingMessagesBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pending_outlined, color: Colors.amber.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pending Messages',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.amber.shade800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You have $_pendingMessageCount pending message${_pendingMessageCount == 1 ? '' : 's'} with this user. Messages will be delivered when you follow each other.',
            style: TextStyle(
              color: Colors.amber.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsSection() {
    return Consumer<DatabaseProvider>(
      builder: (context, databaseProvider, child) {
        // Get posts by this user
        final userPosts = databaseProvider.posts
            .where((post) => post['userId'] == widget.user['uid'])
            .toList();

        // Sort posts by creation date (newest first)
        userPosts.sort((a, b) {
          final aTime = a['createdAt']?.toDate() ?? DateTime.now();
          final bTime = b['createdAt']?.toDate() ?? DateTime.now();
          return bTime.compareTo(aTime);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Posts Header
            Row(
              children: [
                const Icon(
                  Icons.photo_outlined,
                  size: 20,
                  color: Colors.black87,
                ),
                const SizedBox(width: 8),
                Text(
                  'Posts (${userPosts.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Posts Grid/List
            if (userPosts.isEmpty)
              _buildEmptyPostsWidget()
            else
              _buildPostsList(userPosts),
          ],
        );
      },
    );
  }

  Widget _buildEmptyPostsWidget() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This user hasn\'t shared any food adventures yet',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<Map<String, dynamic>> posts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0, // Square posts
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostGridCard(posts[index]);
      },
    );
  }

  Widget _buildPostGridCard(Map<String, dynamic> post) {
    return GestureDetector(
      onTap: () => _openPostDetail(post),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Post Image
              if (post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty)
                Image.network(
                  post['imageUrl'].toString(),
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 24,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Failed to load',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else
                Container(
                  color: Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 24,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No image',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Overlay with post stats (bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${post['likesCount'] ?? 0}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.chat_bubble,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${post['commentsCount'] ?? 0}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final userName = post['userName'] ?? widget.user['name'] ?? 'User';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Image
          if (post['imageUrl'] != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Image.network(
                  post['imageUrl'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
              ),
            ),

          // Post Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User header (simplified for profile view)
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatPostTime(post['createdAt']?.toDate()),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                if (post['location'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          post['location'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Caption
                if (post['caption'] != null && post['caption'].toString().isNotEmpty) ...[
                  Text(
                    post['caption'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Hashtags
                if (post['hashtags'] != null && (post['hashtags'] as List).isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (post['hashtags'] as List).map((hashtag) {
                      return Text(
                        hashtag,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],

                // Post stats
                Row(
                  children: [
                    Icon(
                      Icons.favorite_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['likesCount'] ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post['commentsCount'] ?? 0}',
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
        ],
      ),
    );
  }

  String _formatPostTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _openPostDetail(Map<String, dynamic> post) {
    // Show detailed post view in a modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildPostCard(post),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}