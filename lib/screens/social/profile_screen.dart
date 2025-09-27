import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import 'edit_profile_screen.dart';

class SocialProfileScreen extends StatefulWidget {
  const SocialProfileScreen({super.key});

  @override
  State<SocialProfileScreen> createState() => _SocialProfileScreenState();
}

class _SocialProfileScreenState extends State<SocialProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _userPosts = [];
  List<Map<String, dynamic>> _userReviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _userPosts = CurrentUser.currentUserPosts;
          _userReviews = CurrentUser.currentUserReviews;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = CurrentUser.currentUserData;

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
          'Profile',
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.share_outlined,
                color: Colors.black87,
                size: 20,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share profile coming soon!')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile Picture and Stats
                  Row(
                    children: [
                      // Profile Picture
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(currentUser['name'] ?? ''),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Stats
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              '${_userPosts.length}',
                              'Posts',
                            ),
                            _buildStatItem(
                              '${currentUser['followersCount'] ?? 0}',
                              'Followers',
                            ),
                            _buildStatItem(
                              '${currentUser['followingCount'] ?? 0}',
                              'Following',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Name and Username - BIGGER USERNAME as requested
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name with verification
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentUser['name'] ?? 'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (currentUser['isVerified'] == true) ...[
                            const SizedBox(width: 8),
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
                      const SizedBox(height: 4),
                      // USERNAME - MADE BIGGER as requested
                      Center(
                        child: Text(
                          '@${currentUser['username'] ?? 'username'}',
                          style: TextStyle(
                            fontSize: 18, // Increased from typical 14-16 to 18
                            fontWeight: FontWeight.w600, // Made bolder
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bio
                  if (currentUser['bio'] != null && currentUser['bio'].isNotEmpty) ...[
                    Text(
                      currentUser['bio'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Rating
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${currentUser['rating'] ?? 0} rating',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Edit Profile Button - WORKING as requested
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Food Preferences - NO EDIT BUTTON as requested
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
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
                  // Title WITHOUT edit button as requested
                  const Text(
                    'Food Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preferences Grid
                  if (currentUser['foodPreferences'] != null) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (currentUser['foodPreferences'] as List).map((pref) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            pref,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    Text(
                      'No food preferences set',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                children: [
                  // Tab Headers
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: TabBar(
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
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.grid_on, size: 18),
                              const SizedBox(width: 6),
                              Text('Posts (${_userPosts.length})'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_outline, size: 18),
                              const SizedBox(width: 6),
                              Text('Reviews (${_userReviews.length})'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Content
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPostsTab(),
                        _buildReviewsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsTab() {
    if (_isLoading) {
      return _buildLoadingGrid();
    }

    if (_userPosts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.photo_outlined,
        title: 'No posts yet',
        subtitle: 'Share your food adventures!',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _userPosts.length,
      itemBuilder: (context, index) {
        final post = _userPosts[index];
        return GestureDetector(
          onTap: () => _viewPost(post),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post['imageUrl'] ??
                    'https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=800&q=80',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    if (_isLoading) {
      return _buildLoadingList();
    }

    if (_userReviews.isEmpty) {
      return _buildEmptyState(
        icon: Icons.star_outline,
        title: 'No reviews yet',
        subtitle: 'Share your dining experiences!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userReviews.length,
      itemBuilder: (context, index) {
        final review = _userReviews[index];
        final reviewer = DummyData.getUserById(review['reviewerId']);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(reviewer?['name'] ?? ''),
                        style: TextStyle(
                          fontSize: 12,
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
                        Text(
                          reviewer?['name'] ?? 'Anonymous',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < (review['rating'] ?? 0)
                                  ? Icons.star
                                  : Icons.star_outline,
                              color: Colors.amber.shade600,
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTimeAgo(review['timestamp']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review['text'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: 100,
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
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 12,
                width: double.infinity,
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  void _viewPost(Map<String, dynamic> post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post detail view coming soon!')),
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

  String _formatTimeAgo(String timestamp) {
    try {
      final reviewTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(reviewTime);

      if (difference.inDays < 1) {
        return 'Today';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()}w ago';
      } else {
        return '${(difference.inDays / 30).floor()}mo ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}