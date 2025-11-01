import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/skeleton_widgets.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/auth_controller.dart';
import '../../auth/presentation/login/login_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _updateControllerFromUser(UserModel? user) {
    if (user != null) {
      if (_nameController.text != user.name) {
        _nameController.text = user.name;
      }
      final email = user.email.isNotEmpty ? user.email : (FirebaseAuth.instance.currentUser?.email ?? '');
      if (_emailController.text != email) {
        _emailController.text = email;
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await repository.updateUserProfile(
          userId: currentUser.uid,
          name: _nameController.text.trim(),
        );
        ref.invalidate(currentUserProvider);
        setState(() => _isEditing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isLoading = true);

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Upload to Cloudinary - linked to user ID
      final file = File(image.path);
      final photoUrl = await CloudinaryService.uploadProfilePicture(
        imageFile: file,
        userId: currentUser.uid,
      );

      // Update user profile in Firebase with Cloudinary URL
      final repository = ref.read(authRepositoryProvider);
      await repository.updateUserProfile(
        userId: currentUser.uid,
        photoUrl: photoUrl,
      );

      ref.invalidate(currentUserProvider);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repository = ref.read(authRepositoryProvider);
        await repository.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing out: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final currentUser = FirebaseAuth.instance.currentUser;

    // Update controller when user data changes
    userAsync.whenData((user) {
      if (user != null && user != _currentUser) {
        _currentUser = user;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isEditing) {
            _updateControllerFromUser(user);
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _updateProfile,
              child: const Text('Save'),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user data'));
          }

          // Ensure controllers have the latest values
          if (!_isEditing) {
            if (_nameController.text != user.name) {
              _nameController.text = user.name;
            }
            final email = user.email.isNotEmpty ? user.email : (currentUser?.email ?? '');
            if (_emailController.text != email) {
              _emailController.text = email;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: user.photoUrl != null
                          ? CachedNetworkImageProvider(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(
                              user.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 48),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 20),
                            color: Theme.of(context).colorScheme.onPrimary,
                            onPressed: _isLoading ? null : _pickAndUploadImage,
                          ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (_isLoading) const LinearProgressIndicator(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  enabled: _isEditing,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: user.isOnline 
                          ? Theme.of(context).colorScheme.tertiary 
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  title: Text(user.isOnline ? 'Online' : 'Offline'),
                  subtitle: Text(
                    'Last seen: ${user.isOnline ? "Now" : user.lastSeen != null ? user.lastSeen.toString() : "Never"}',
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleSignOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const ProfileSkeleton(),
        error: (error, stack) => ErrorDisplayWidget(
          message: 'Error loading profile: $error',
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
      ),
    );
  }
}


