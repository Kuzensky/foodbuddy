import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // State variables
  List<String> _selectedFoodPreferences = [];
  List<String> _selectedInterests = [];
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final currentUser = CurrentUser.currentUserData;

    _nameController.text = currentUser['name'] ?? '';
    _usernameController.text = currentUser['username'] ?? '';
    _emailController.text = currentUser['email'] ?? '';
    _bioController.text = currentUser['bio'] ?? '';
    _locationController.text = currentUser['location'] ?? '';

    _selectedFoodPreferences = List<String>.from(currentUser['foodPreferences'] ?? []);
    _selectedInterests = List<String>.from(currentUser['interests'] ?? []);

    // Add listeners to detect changes
    _nameController.addListener(_onFormChanged);
    _usernameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _bioController.addListener(_onFormChanged);
    _locationController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {
      _hasChanges = true;
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
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => _onBackPressed(),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _hasChanges ? _saveProfile : null,
            child: Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _hasChanges ? Colors.blue.shade600 : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(),

              const SizedBox(height: 24),

              // Basic Information
              _buildBasicInformationSection(),

              const SizedBox(height: 24),

              // Bio Section
              _buildBioSection(),

              const SizedBox(height: 24),

              // Food Preferences Section
              _buildFoodPreferencesSection(),

              const SizedBox(height: 24),

              // Interests Section
              _buildInterestsSection(),

              const SizedBox(height: 24),

              // Account Settings Section
              _buildAccountSettingsSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Container(
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
        children: [
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 3),
                ),
                child: Center(
                  child: Text(
                    _getInitials(_nameController.text),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _changeProfilePicture,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Change Profile Picture',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformationSection() {
    return Container(
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
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Name Field
          _buildTextFieldWithLabel(
            label: 'Full Name',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Username Field
          _buildTextFieldWithLabel(
            label: 'Username',
            controller: _usernameController,
            prefixText: '@',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username is required';
              }
              if (value.length < 3) {
                return 'Username must be at least 3 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email Field
          _buildTextFieldWithLabel(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Location Field
          _buildTextFieldWithLabel(
            label: 'Location',
            controller: _locationController,
            suffixIcon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
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
          const Text(
            'About You',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _bioController,
            maxLines: 4,
            maxLength: 150,
            decoration: InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell others about your food journey...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodPreferencesSection() {
    return Container(
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
          const Text(
            'Food Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your favorite cuisines and dietary preferences',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DummyData.allFoodPreferences.map((preference) {
              final isSelected = _selectedFoodPreferences.contains(preference);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFoodPreferences.remove(preference);
                    } else {
                      _selectedFoodPreferences.add(preference);
                    }
                    _hasChanges = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    preference,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    final interests = [
      'Fine Dining', 'Cooking', 'Food Photography', 'Wine Tasting',
      'Baking', 'Vegetarian Cooking', 'Recipe Development', 'Food Blogging',
      'Restaurant Reviews', 'Craft Beer', 'Coffee Culture', 'Street Food',
      'Food Travel', 'Healthy Eating', 'Meal Planning', 'Food Pairing'
    ];

    return Container(
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
          const Text(
            'Interests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What are you passionate about in the food world?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest);
                    } else {
                      _selectedInterests.add(interest);
                    }
                    _hasChanges = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.green.shade600 : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsSection() {
    return Container(
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
          const Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Change password coming soon!')),
              );
            },
          ),

          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notification Settings',
            subtitle: 'Manage your notification preferences',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification settings coming soon!')),
              );
            },
          ),

          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Settings',
            subtitle: 'Control who can see your profile',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings coming soon!')),
              );
            },
          ),

          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with your account',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & support coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldWithLabel({
    required String label,
    required TextEditingController controller,
    String? prefixText,
    IconData? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey.shade500) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.grey.shade600),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey.shade400,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _changeProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture upload coming soon!')),
    );
  }

  void _onBackPressed() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to go back?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Discard',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate saving
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
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
}