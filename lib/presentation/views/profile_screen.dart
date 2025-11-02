import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../widgets/arc_clipper.dart';
import '../widgets/profile_avatar.dart';

class ProfileScreen extends GetView<AuthController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          ClipPath(
            clipper: ArcClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.42,
              color: colorScheme.primary,
            ),
          ),
          Obx(() {
            final user = controller.currentUser.value;
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    ProfileAvatar(user: user, radius: 60),
                    const SizedBox(height: 16),
                    Text(
                      user.fullName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => controller.signOut(),
                      icon: const Icon(Icons.logout),
                      label: const Text('LOGOUT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
