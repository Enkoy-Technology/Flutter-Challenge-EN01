import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart' as app_auth;
import '../../widgets/profile_header.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/profile_info_card.dart';

class ProfilePage extends StatefulWidget {
  final bool showBackButton;

  const ProfilePage({super.key, this.showBackButton = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _authRepository = AuthRepository(Supabase.instance.client);
  bool _isEditing = false;
  bool _isLoading = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is app_auth.AuthAuthenticated) {
      final user = authState.user;
      setState(() {
        _displayNameController.text = user.displayName;
        _bioController.text = user.bio ?? '';
        _avatarUrl = user.avatarUrl;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final userId = Supabase.instance.client.auth.currentUser!.id;

        // Upload avatar
        final avatarUrl = await _authRepository.uploadAvatar(
          userId,
          image.path,
        );

        // Update user profile with new avatar URL
        await _authRepository.updateUserProfile(
          userId: userId,
          avatarUrl: avatarUrl,
        );

        // Update local state
        setState(() {
          _avatarUrl = avatarUrl;
          _isLoading = false;
        });

        // Reload profile to get fresh data
        await _loadUserProfile();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile picture: ${e.toString().contains('Exception:') ? e.toString().split('Exception:')[1].trim() : 'Please try again'}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await _authRepository.updateUserProfile(
        userId: userId,
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh auth state
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFullImage() {
    if (_avatarUrl == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(_avatarUrl!, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<AuthBloc, app_auth.AuthState>(
        builder: (context, state) {
          if (state is! app_auth.AuthAuthenticated) {
            return const Center(child: Text('Not authenticated'));
          }

          final user = state.user;

          return Column(
            children: [
              // Header
              ProfileHeader(
                showBackButton: widget.showBackButton,
                isEditing: _isEditing,
                isLoading: _isLoading,
                onEditPressed: () => setState(() => _isEditing = true),
                onSavePressed: _saveProfile,
              ),
              // Profile Avatar Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                      Colors.grey[100]!,
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                child: ProfileAvatar(
                  avatarUrl: _avatarUrl,
                  displayName: user.displayName,
                  isLoading: _isLoading,
                  onCameraPressed: _pickAndUploadAvatar,
                  onAvatarTap: _showFullImage,
                ),
              ),
              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Email (read-only)
                      ProfileInfoCard(
                        icon: Icons.email,
                        label: 'Email',
                        value: user.email,
                        isEditable: false,
                      ),
                      const SizedBox(height: 12),
                      // Display Name
                      ProfileInfoCard(
                        icon: Icons.person,
                        label: 'Display Name',
                        value: _displayNameController.text,
                        isEditable: _isEditing,
                        controller: _displayNameController,
                      ),
                      const SizedBox(height: 12),
                      // Bio
                      ProfileInfoCard(
                        icon: Icons.info_outline,
                        label: 'Bio',
                        value: _bioController.text.isEmpty
                            ? 'No bio yet'
                            : _bioController.text,
                        isEditable: _isEditing,
                        controller: _bioController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      // Member Since
                      ProfileInfoCard(
                        icon: Icons.calendar_today,
                        label: 'Member Since',
                        value: _formatDate(user.createdAt),
                        isEditable: false,
                      ),
                      const SizedBox(height: 30),
                      // Sign Out Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              AuthSignOutRequested(),
                            );
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
