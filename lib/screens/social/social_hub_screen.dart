import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/database_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/image_manager.dart';
import 'notifications_screen.dart';
import 'create_post_screen.dart';
import 'messages_list_screen.dart';
import 'comments_screen.dart';

class SocialHubScreen extends StatefulWidget {
  const SocialHubScreen({super.key});

  @override
  State<SocialHubScreen> createState() => _SocialHubScreenState();
}

class _SocialHubScreenState extends State<SocialHubScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts();
    });
  }

  void _loadPosts() async {
    try {
      final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      await databaseProvider.loadFeedPosts();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load posts: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
          'Social',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          // Notifications
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.black87,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),

          // Create Post
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.black87,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreatePostScreen()),
              );
            },
          ),
          const SizedBox(width: 8),

          // Messages
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.message_outlined,
                color: Colors.black87,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MessagesListScreen()),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<DatabaseProvider>(
              builder: (context, databaseProvider, child) {
                final posts = databaseProvider.posts;
                return posts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No posts yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start following people or create your first post!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _loadPosts();
                        },
                        child: ListView.builder(
                          itemCount: posts.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            return _buildPostCard(posts[index]);
                          },
                        ),
                      );
              },
            ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid;
    final likedBy = List<String>.from(post['likedBy'] ?? []);
    final isLiked = currentUserId != null && likedBy.contains(currentUserId);

    // Extract user info from post data
    final userName = post['userName'] ?? 'Anonymous User';
    final userEmail = post['userEmail'] ?? '';
    final userPhotoUrl = post['userPhotoUrl'] ?? '';
    final isCurrentUserPost = post['userId'] == currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildProfileAvatar(userName, userPhotoUrl, isCurrentUserPost),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUserPost) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimeAgo(post['createdAt']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () {
                    // Show options menu
                  },
                ),
              ],
            ),
          ),

          // Post image (if available)
          if (post['imageUrl'] != null && post['imageUrl'].isNotEmpty)
            Container(
              width: double.infinity,
              height: 250,
              child: ClipRRect(
                child: _buildImageWidget(post['imageUrl']),
              ),
            ),

          // Post caption
          if (post['caption'] != null && post['caption'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post['caption'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

          // Post actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Like button
                Flexible(
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
                        await databaseProvider.togglePostLike(post['id']);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to like post: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.black87 : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post['likesCount'] ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),

                // Comment button
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommentsScreen(post: post),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.grey.shade600,
                          size: 20,
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
                  ),
                ),
                const SizedBox(width: 24),

                // Share button
                GestureDetector(
                  onTap: () {
                    // Handle share
                  },
                  child: Icon(
                    Icons.share_outlined,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    if (ImageManager.isAssetUrl(imageUrl)) {
      // Asset image
      final assetPath = ImageManager.assetUrlToPath(imageUrl);
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.grey,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      // Network image (for future cloud storage)
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.grey,
                    size: 48,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatTimeAgo(dynamic timestamp) {
    try {
      DateTime postTime;

      // Handle Firestore Timestamp
      if (timestamp is Timestamp) {
        postTime = timestamp.toDate();
      } else if (timestamp is String) {
        postTime = DateTime.parse(timestamp);
      } else if (timestamp == null) {
        return 'now';
      } else {
        return 'now';
      }

      final now = DateTime.now();
      final difference = now.difference(postTime);

      if (difference.inMinutes < 1) {
        return 'now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return '${(difference.inDays / 7).floor()}w';
      }
    } catch (e) {
      return 'now';
    }
  }

  Widget _buildProfileAvatar(String userName, String userPhotoUrl, bool isCurrentUserPost) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCurrentUserPost ? Colors.blue.shade100 : Colors.grey.shade200,
        shape: BoxShape.circle,
        border: isCurrentUserPost
            ? Border.all(color: Colors.blue, width: 2)
            : null,
      ),
      child: userPhotoUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                userPhotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      _getInitials(userName),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCurrentUserPost ? Colors.blue.shade700 : Colors.grey.shade600,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                _getInitials(userName),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCurrentUserPost ? Colors.blue.shade700 : Colors.grey.shade600,
                ),
              ),
            ),
    );
  }
}