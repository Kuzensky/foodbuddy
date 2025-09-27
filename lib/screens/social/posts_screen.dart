import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPosts() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _posts = DummyData.posts;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Posts',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add,
                color: Colors.blue.shade600,
                size: 20,
              ),
            ),
            onPressed: () => _showCreatePostModal(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade600,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade600,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'My Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(),
          _buildMyPostsTab(),
        ],
      ),
    );
  }

  Widget _buildFeedTab() {
    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isLoading = true;
        });
        _loadPosts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(_posts[index]);
        },
      ),
    );
  }

  Widget _buildMyPostsTab() {
    final myPosts = _posts.where((post) => post['userId'] == CurrentUser.userId).toList();

    if (_isLoading) {
      return _buildSkeletonLoading();
    }

    if (myPosts.isEmpty) {
      return _buildEmptyMyPosts();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myPosts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(myPosts[index]);
      },
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
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
              // User skeleton
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Image skeleton
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              // Text skeleton
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyMyPosts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your food adventures with the community!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreatePostModal(),
            icon: const Icon(Icons.add),
            label: const Text('Create Your First Post'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final user = DummyData.getUserById(post['userId']);
    final restaurant = post['restaurantId'] != null
        ? DummyData.getRestaurantById(post['restaurantId'])
        : null;
    final isLiked = post['isLikedByCurrentUser'] ?? false;

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
          // User Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(user?['name'] ?? ''),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user?['name'] ?? 'Unknown User',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          if (user?['isVerified'] == true) ...[
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
                      if (post['location'] != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                post['location'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  _formatTimeAgo(post['timestamp']),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.more_vert,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),

          // Post Image
          Container(
            height: 250,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post['imageUrl'] ??
                    'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=800&q=80',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),

          // Post Actions and Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action Buttons
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _handleLike(post),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatCount(post['likesCount'] ?? 0),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => _handleComment(post),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.grey.shade600,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatCount(post['commentsCount'] ?? 0),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => _handleShare(post),
                      child: Row(
                        children: [
                          Icon(
                            Icons.share_outlined,
                            color: Colors.grey.shade600,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatCount(post['sharesCount'] ?? 0),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.bookmark_border,
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Post Caption
                if (post['caption'] != null && post['caption'].isNotEmpty) ...[
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '${user?['name'] ?? 'User'} ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(text: post['caption']),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Hashtags
                if (post['hashtags'] != null &&
                    (post['hashtags'] as List).isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: (post['hashtags'] as List).map((hashtag) {
                      return Text(
                        hashtag,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                ],

                // Restaurant info
                if (restaurant != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            restaurant['name'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Text(
                          '${restaurant['rating'] ?? 0}★',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostModal(),
    );
  }

  void _handleLike(Map<String, dynamic> post) {
    setState(() {
      final isCurrentlyLiked = post['isLikedByCurrentUser'] ?? false;
      post['isLikedByCurrentUser'] = !isCurrentlyLiked;
      post['likesCount'] =
          (post['likesCount'] ?? 0) + (!isCurrentlyLiked ? 1 : -1);
    });
  }

  void _handleComment(Map<String, dynamic> post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comments feature coming soon!')),
    );
  }

  void _handleShare(Map<String, dynamic> post) {
    setState(() {
      post['sharesCount'] = (post['sharesCount'] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post shared!')),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
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

  String _formatTimeAgo(String timestamp) {
    try {
      final postTime = DateTime.parse(timestamp);
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
      return '1h';
    }
  }
}

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({super.key});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedImage;
  Map<String, dynamic>? _selectedRestaurant;

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Create Post',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _createPost,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(CurrentUser.currentUserData['name'] ?? ''),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        CurrentUser.currentUserData['name'] ?? 'User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Caption input
                  TextField(
                    controller: _captionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'What\'s happening with your food adventure?',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Photo section
                  GestureDetector(
                    onTap: _selectImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location input
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey.shade500),
                      hintText: 'Add location',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Restaurant tagging
                  GestureDetector(
                    onTap: _selectRestaurant,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant_outlined, color: Colors.grey.shade500),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedRestaurant != null
                                  ? _selectedRestaurant!['name']
                                  : 'Tag restaurant',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedRestaurant != null
                                    ? Colors.black87
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectImage() {
    // Simulate image selection
    setState(() {
      _selectedImage = 'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=800&q=80';
    });
  }

  void _selectRestaurant() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Restaurant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: DummyData.restaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = DummyData.restaurants[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.restaurant, color: Colors.grey),
                      ),
                      title: Text(restaurant['name']),
                      subtitle: Text(restaurant['cuisine']),
                      onTap: () {
                        setState(() {
                          _selectedRestaurant = restaurant;
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _createPost() {
    if (_captionController.text.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a caption or photo')),
      );
      return;
    }

    // Simulate post creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post created successfully!')),
    );
    Navigator.of(context).pop();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final names = name.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}