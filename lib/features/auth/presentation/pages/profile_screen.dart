import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_app/core/config/app_router.dart';
import 'package:flutter_chat_app/core/di/injector.dart';
import 'package:flutter_chat_app/core/services/firebase_storage_service.dart';
import 'package:flutter_chat_app/core/services/theme_service.dart';
import 'package:flutter_chat_app/core/services/preferences_service.dart';
import 'package:flutter_chat_app/features/auth/data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? userModel;
  bool isLoading = true;
  bool isUpdating = false;
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            userModel = UserModel.fromMap({
              'uid': user.uid,
              ...snapshot.data()!,
            });
            _nameController.text = userModel?.name ?? '';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() => isUpdating = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isUpdating = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
        }
        return;
      }

      final storageService = sl<FirebaseStorageService>();
      final file = File(image.path);

      // Check if file exists
      if (!await file.exists()) {
        setState(() => isUpdating = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected file does not exist')),
          );
        }
        return;
      }

      // Try to delete old profile picture if exists (optional)
      // We'll overwrite it anyway, so this is just for cleanup
      final oldPath = 'profile_pics/${user.uid}.jpg';
      try {
        await storageService.deleteFile(oldPath);
      } catch (e) {
        // Ignore if file doesn't exist - this is expected for new users
        print('Note: Could not delete old file (may not exist): $e');
      }

      // Upload new file
      final imageUrl = await storageService.uploadFile(
        oldPath,
        file,
      );

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'avatarUrl': imageUrl});

      // Refresh user data
      await _fetchUserData();

      setState(() => isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating photo: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      print('Error in _pickImage: $e');
    }
  }

  Future<void> _updateName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => isUpdating = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'name': _nameController.text.trim()});

        await user.updateDisplayName(_nameController.text.trim());
        await _fetchUserData();

        setState(() => isUpdating = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Name updated successfully')),
          );
        }
      }
    } catch (e) {
      setState(() => isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating name: $e')),
        );
      }
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.login);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final preferencesService = Provider.of<PreferencesService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Settings"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Section
                    _buildProfileSection(context),
                    const SizedBox(height: 24),

                    // Account Settings
                    _buildSectionTitle('Account Settings'),
                    const SizedBox(height: 12),
                    _buildAccountSettings(context),
                    const SizedBox(height: 24),

                    // App Settings
                    _buildSectionTitle('App Settings'),
                    const SizedBox(height: 12),
                    _buildAppSettings(context, themeService, preferencesService),
                    const SizedBox(height: 24),

                    // Notification Settings
                    _buildSectionTitle('Notifications'),
                    const SizedBox(height: 12),
                    _buildNotificationSettings(context, preferencesService),
                    const SizedBox(height: 32),

                    // Logout Button
                    _buildLogoutButton(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  backgroundImage: userModel?.avatarUrl != null
                      ? NetworkImage(userModel!.avatarUrl!)
                      : null,
                  child: userModel?.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
                if (isUpdating)
                  const Positioned.fill(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: isUpdating ? null : _pickImage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              userModel?.name ?? "User Name",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              userModel?.email ?? "user@example.com",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Display Name'),
            subtitle: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
                border: InputBorder.none,
              ),
            ),
            trailing: isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _updateName,
                  ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(userModel?.email ?? ''),
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings(
    BuildContext context,
    ThemeService themeService,
    PreferencesService preferencesService,
  ) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark theme'),
            value: themeService.isDarkMode,
            onChanged: (value) => themeService.toggleTheme(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(
    BuildContext context,
    PreferencesService preferencesService,
  ) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            subtitle: const Text('Receive push notifications'),
            value: preferencesService.notificationsEnabled,
            onChanged: (value) =>
                preferencesService.setNotificationsEnabled(value),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text('Sound'),
            subtitle: const Text('Play sound for notifications'),
            value: preferencesService.soundEnabled,
            onChanged: preferencesService.notificationsEnabled
                ? (value) => preferencesService.setSoundEnabled(value)
                : null,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Vibration'),
            subtitle: const Text('Vibrate for notifications'),
            value: preferencesService.vibrationEnabled,
            onChanged: preferencesService.notificationsEnabled
                ? (value) => preferencesService.setVibrationEnabled(value)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        onTap: _logout,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
