
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart';
import '../providers/database_provider.dart';
import '../services/firebase_service.dart';
import '../widgets/social/skeleton_loading.dart';
import 'followers_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _selectedTab = 'Posts'; // Track which tab is selected
  bool _isEditingBio = false;
  bool _isEditingTags = false;
  final TextEditingController _bioController = TextEditingController();
  List<String> _foodTags = ['Italian', 'Vegetarian', 'Asian Cuisine'];
  late Map<String, dynamic> _currentUser;
  List<Map<String, dynamic>> _userPosts = [];
  List<Map<String, dynamic>> _userMeetups = [];
  List<Map<String, dynamic>> _userReviews = [];
  bool _hasLoadedDependencies = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserDataFromDatabase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load once per navigation to avoid infinite loops
    if (!_hasLoadedDependencies) {
      _hasLoadedDependencies = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadUserDataFromDatabase();
        }
      });
    }
  }

  Future<void> _loadUserDataFromDatabase() async {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final currentUserId = authProvider.currentUser?.uid;

    if (currentUserId != null) {
      _currentUser = databaseProvider.users.firstWhere(
        (user) => user['id'] == currentUserId,
        orElse: () => {
          'id': currentUserId,
          'name': authProvider.currentUser?.displayName ?? 'User',
          'email': authProvider.currentUser?.email ?? '',
          'bio': "Food enthusiast who loves exploring new cuisines and meeting fellow food lovers!",
          'foodPreferences': ['Italian', 'Vegetarian', 'Asian Cuisine'],
        },
      );

      // Load posts from database first
      try {
        await databaseProvider.loadFeedPosts();
        if (kDebugMode) {
          debugPrint('Profile: Loaded ${databaseProvider.posts.length} total posts from database');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Profile: Error loading posts: $e');
        }
      }

      // Load user's posts - make sure to refresh posts data
      _userPosts = databaseProvider.posts
          .where((post) => post['userId'] == currentUserId)
          .toList();

      // Debug: Print post count and image info
      if (kDebugMode) {
        debugPrint('Profile: Found ${_userPosts.length} user posts out of ${databaseProvider.posts.length} total');
        for (var post in _userPosts) {
          debugPrint('Post ID: ${post['id']}, Has image: ${post['imageUrl'] != null}, ImageURL: ${post['imageUrl']}');
        }
      }

      _userMeetups = databaseProvider.userSessions;
      _userReviews = databaseProvider.reviews
          .where((review) => review['userId'] == currentUserId)
          .toList();

      _bioController.text = _currentUser['bio'] ?? "Food enthusiast who loves exploring new cuisines and meeting fellow food lovers!";
      _foodTags = List<String>.from(_currentUser['foodPreferences'] ?? ['Italian', 'Vegetarian', 'Asian Cuisine']);

      // Refresh the UI
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await FirebaseService().getUserData(user.uid);
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    await authProvider.signOut();
    if (mounted) {
      navigator.pushReplacementNamed('/login');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Social Data'),
          content: const Text(
            'This will permanently delete all posts, likes, follows, notifications, and messages while keeping users and restaurants intact.\n\nAre you sure you want to continue?'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _executeClearSocialData(context);
              },
              child: const Text(
                'Clear Data',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeClearSocialData(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Clearing Data'),
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Clearing social data...'),
              ],
            ),
          );
        },
      );

      // Execute the cleanup
      final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      await databaseProvider.clearSocialFeedData();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Social data cleared successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      // Close loading dialog if it's showing
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error clearing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addSamplePosts(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Adding Sample Posts'),
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Creating posts with images...'),
              ],
            ),
          );
        },
      );

      final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final currentUserId = authProvider.currentUser?.uid;

      if (currentUserId != null) {
        // Create sample posts for the current user
        final samplePosts = [
          {
            'userId': currentUserId,
            'imageUrl': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&q=85',
            'caption': 'Amazing truffle pasta! The flavor combination was absolutely perfect. 🍝✨',
            'location': 'Italian Restaurant',
            'hashtags': ['#ItalianFood', '#TrufflePasta', '#Foodie'],
            'likesCount': 5,
            'commentsCount': 2,
          },
          {
            'userId': currentUserId,
            'imageUrl': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&q=85',
            'caption': 'Perfect BBQ burger! Juicy patty, crispy bacon, and secret sauce. 🍔',
            'location': 'Burger Junction',
            'hashtags': ['#Burger', '#BBQ', '#ComfortFood'],
            'likesCount': 8,
            'commentsCount': 1,
          },
          {
            'userId': currentUserId,
            'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=85',
            'caption': 'Colorful Buddha bowl packed with nutrients! Plant-based eating at its finest! 🌱',
            'location': 'Health Café',
            'hashtags': ['#HealthyFood', '#Vegan', '#BuddhaBowl'],
            'likesCount': 12,
            'commentsCount': 3,
          },
        ];

        // Add posts to database
        for (var postData in samplePosts) {
          await databaseProvider.createPost({
            'imageUrl': postData['imageUrl'],
            'caption': postData['caption'],
            'location': postData['location'],
            'hashtags': postData['hashtags'],
          });
        }

        // Refresh the posts
        await _loadUserDataFromDatabase();
      }

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Sample posts added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      // Close loading dialog if it's showing
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error adding posts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.grey),
                title: const Text(
                  'Preferences',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preferences feature coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.storage, color: Colors.blue),
                title: const Text(
                  'Database Setup',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                subtitle: const Text(
                  'Populate database with sample users',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/database_setup');
                },
              ),
              ListTile(
                leading: const Icon(Icons.cleaning_services, color: Colors.orange),
                title: const Text(
                  'Clear Social Data',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                subtitle: const Text(
                  'Remove all posts, likes, follows, messages',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showClearDataDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_photo_alternate, color: Colors.green),
                title: const Text(
                  'Add Sample Posts',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                subtitle: const Text(
                  'Add sample posts with images for testing',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _addSamplePosts(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        );
      },
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

  // Dynamic follow stats that reload real-time data
  Widget _buildDynamicFollowStats() {
    return Consumer<DatabaseProvider>(
      builder: (context, databaseProvider, child) {
        return FutureBuilder<Map<String, int>>(
          future: databaseProvider.getFollowStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  _buildModernStatColumn('...', 'Followers'),
                  const SizedBox(width: 32),
                  _buildModernStatColumn('...', 'Following'),
                ],
              );
            }

            final stats = snapshot.data ?? {'followersCount': 0, 'followingCount': 0};
            final followersCount = _formatCount(stats['followersCount'] ?? 0);
            final followingCount = _formatCount(stats['followingCount'] ?? 0);

            return Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToFollowers('followers'),
                  child: _buildModernStatColumn(followersCount, 'Followers'),
                ),
                const SizedBox(width: 32),
                GestureDetector(
                  onTap: () => _navigateToFollowers('following'),
                  child: _buildModernStatColumn(followingCount, 'Following'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToFollowers(String tab) {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final currentUserId = databaseProvider.currentUserId;
    final userName = _currentUser['name'] ?? 'User';

    if (currentUserId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FollowersScreen(
            userId: currentUserId,
            userName: userName,
            initialTab: tab,
          ),
        ),
      );
    }
  }


  // Modern stat column for the redesigned profile info
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

  // Modern rating column with star icon
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

  // Subtle divider between stats
  Widget _buildStatDivider() {
    return Container(
      height: 32,
      width: 1,
      color: Colors.grey.shade300,
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppAuthProvider>().currentUser;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const ProfileStatsSkeleton(),
      );
    }

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Not logged in'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final userName = _currentUser['name'] ?? _userData?['name'] ?? user.displayName ?? 'User';
    final userInitials = _getInitials(userName);
    final rating = (_currentUser['rating'] ?? 0.0).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Username on left
            Text(
              userName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Settings icon (3 lines) on right
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                _showSettingsMenu(context);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Info Section
              _buildProfileInfo(user, userName, userInitials, rating),

              const SizedBox(height: 24),

              // Bio Section
              _buildBioSection(),

              const SizedBox(height: 20),

              // Food Preference Tags Section
              _buildFoodTagsSection(),

              const SizedBox(height: 24),

              // Edit Profile Button
              _buildEditProfileButton(),

              const SizedBox(height: 32),

              // Tabs Section (Posts, Meetups, Reviews)
              _buildTabsSection(),

              const SizedBox(height: 16),

              // Content based on selected tab
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  // Modern Profile Info Section - Clean and Minimal Design
  Widget _buildProfileInfo(User user, String userName, String userInitials, String rating) {
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
                  backgroundImage: _currentUser['profilePicture'] != null
                      ? NetworkImage(_currentUser['profilePicture']) as ImageProvider
                      : (user.photoURL != null
                          ? NetworkImage(user.photoURL!) as ImageProvider
                          : null),
                  child: (_currentUser['profilePicture'] == null && user.photoURL == null)
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
                  if (_currentUser['isVerified'] == true || user.emailVerified) ...[
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
            ],
          ),

          const SizedBox(height: 32),

          // Stats Section - Clean horizontal layout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Consumer<DatabaseProvider>(
                  builder: (context, dbProvider, child) {
                    final currentUserId = Provider.of<AppAuthProvider>(context, listen: false).currentUser?.uid;
                    final userPosts = dbProvider.posts
                        .where((post) => post['userId'] == currentUserId)
                        .toList();
                    return _buildModernStatColumn(userPosts.length.toString(), 'Posts');
                  },
                ),
                _buildStatDivider(),
                _buildDynamicFollowStats(),
                _buildStatDivider(),
                _buildModernRatingColumn(rating),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bio Section (editable)
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
        _isEditingBio
          ? Column(
              children: [
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditingBio = false;
                        });
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditingBio = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bio updated!')),
                        );
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  _isEditingBio = true;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  _bioController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
      ],
    );
  }

  // Food Preference Tags Section (editable)
  Widget _buildFoodTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Food Preferences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            if (!_isEditingTags)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditingTags = true;
                  });
                },
                child: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _isEditingTags
          ? Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _foodTags.asMap().entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _foodTags.removeAt(entry.key);
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isEditingTags = false;
                        });
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _foodTags.map((tag) => _buildTag(tag)).toList(),
            ),
      ],
    );
  }

  // Edit Profile Button
  Widget _buildEditProfileButton() {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit profile feature coming soon!')),
          );
        },
        child: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Tabs Section (Posts, Meetups, Reviews)
  Widget _buildTabsSection() {
    return Row(
      children: [
        _buildTab('Posts'),
        _buildTab('Meetups'),
        _buildTab('Reviews'),
      ],
    );
  }

  Widget _buildTab(String tabName) {
    bool isSelected = _selectedTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tabName;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            tabName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // Content based on selected tab
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'Posts':
        return _buildPostsGrid();
      case 'Meetups':
        return _buildMeetupsContent();
      case 'Reviews':
        return _buildReviewsContent();
      default:
        return _buildPostsGrid();
    }
  }

  // Posts Grid with actual user posts
  Widget _buildPostsGrid() {
    return Consumer<DatabaseProvider>(
      builder: (context, dbProvider, child) {
        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
        final currentUserId = authProvider.currentUser?.uid;

        if (currentUserId == null) {
          return Container(
            height: 120,
            child: const Center(child: Text('Please log in to see posts')),
          );
        }

        // Get user posts from database provider
        final userPosts = dbProvider.posts
            .where((post) => post['userId'] == currentUserId)
            .toList();

        if (kDebugMode) {
          debugPrint('Profile Grid: Displaying ${userPosts.length} posts');
        }

        if (userPosts.isEmpty) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: Colors.grey.shade400,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No posts yet',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];

        // Debug logging for image issues
        if (kDebugMode) {
          final imageUrl = post['imageUrl'];
          if (imageUrl == null || imageUrl.toString().isEmpty) {
            debugPrint('Post ${post['id']} has no imageUrl');
          } else {
            debugPrint('Post ${post['id']} imageUrl: $imageUrl');
          }
        }

        return GestureDetector(
          onTap: () {
            _showPostDetails(post);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200, width: 0.5),
            ),
            child: Stack(
              children: [
                // Post image
                if (post['imageUrl'] != null && post['imageUrl'].toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post['imageUrl'],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        if (kDebugMode) {
                          debugPrint('Image load error for ${post['imageUrl']}: $error');
                        }
                        return _buildPostPlaceholder(post);
                      },
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
                    ),
                  )
                else
                  _buildPostPlaceholder(post),

                // Overlay for likes count
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${post['likesCount'] ?? 0}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
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
      },
    );
      },
    );
  }

  // Placeholder for posts without images or when image fails to load
  Widget _buildPostPlaceholder(Map<String, dynamic> post) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 28,
              color: Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              'No Image',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Meetups Content
  Widget _buildMeetupsContent() {
    if (_userMeetups.isEmpty) {
      return Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Colors.grey.shade400,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'No meetups yet',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userMeetups.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final meetup = _userMeetups[index];
        final restaurant = Provider.of<DatabaseProvider>(context, listen: false)
            .restaurants.firstWhere(
              (r) => r['id'] == meetup['restaurantId'],
              orElse: () => {'name': 'Unknown Restaurant', 'cuisine': 'Unknown'},
            );
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: Colors.grey.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    restaurant['name'] ?? 'Restaurant',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${meetup['date']} at ${meetup['time']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'Max participants: ${meetup['maxParticipants']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              if (meetup['description'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  meetup['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Reviews Content
  Widget _buildReviewsContent() {
    if (_userReviews.isEmpty) {
      return Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rate_review_outlined,
                color: Colors.grey.shade400,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'No reviews yet',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userReviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final review = _userReviews[index];
        final restaurant = review['restaurantId'] != null
            ? Provider.of<DatabaseProvider>(context, listen: false)
                .restaurants.firstWhere(
                  (r) => r['id'] == review['restaurantId'],
                  orElse: () => {'name': 'Unknown Restaurant'},
                )
            : null;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      restaurant?['name'] ?? 'Restaurant',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < (review['rating'] ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
              if (review['review'] != null && review['review'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  review['review'].toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                (review['date'] ?? '').toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  IconData _getFoodIcon(List<dynamic> hashtags) {
    final hashtagsStr = hashtags.join(' ').toLowerCase();

    if (hashtagsStr.contains('pizza')) return Icons.local_pizza;
    if (hashtagsStr.contains('pasta') || hashtagsStr.contains('italian')) return Icons.restaurant;
    if (hashtagsStr.contains('bbq') || hashtagsStr.contains('meat')) return Icons.outdoor_grill;
    if (hashtagsStr.contains('vegan') || hashtagsStr.contains('healthy')) return Icons.eco;
    if (hashtagsStr.contains('korean')) return Icons.ramen_dining;
    if (hashtagsStr.contains('dessert') || hashtagsStr.contains('cake') || hashtagsStr.contains('chocolate')) return Icons.cake;
    if (hashtagsStr.contains('coffee')) return Icons.coffee;
    if (hashtagsStr.contains('breakfast')) return Icons.breakfast_dining;
    if (hashtagsStr.contains('lunch')) return Icons.lunch_dining;
    if (hashtagsStr.contains('dinner')) return Icons.dinner_dining;

    return Icons.restaurant_menu;
  }

  void _showPostDetails(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Post Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post['caption'] != null) ...[
                Text(
                  'Caption:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(post['caption']),
                const SizedBox(height: 8),
              ],
              if ((post['hashtags'] as List?)?.isNotEmpty ?? false) ...[
                Text(
                  'Hashtags:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text((post['hashtags'] as List).join(' ')),
                const SizedBox(height: 8),
              ],
              Text(
                'Likes: ${post['likesCount'] ?? 0}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Comments: ${post['commentsCount'] ?? 0}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}