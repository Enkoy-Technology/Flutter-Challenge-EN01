import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final bool showBackButton;
  final bool isEditing;
  final bool isLoading;
  final VoidCallback onEditPressed;
  final VoidCallback onSavePressed;

  const ProfileHeader({
    super.key,
    required this.showBackButton,
    required this.isEditing,
    required this.isLoading,
    required this.onEditPressed,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                )
              else
                const SizedBox(width: 48),
              const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              if (!isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: onEditPressed,
                )
              else
                TextButton.icon(
                  onPressed: isLoading ? null : onSavePressed,
                  icon: const Icon(Icons.check, color: Colors.white, size: 20),
                  label: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

