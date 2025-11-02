import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/chat/presentation/pages/call_screen.dart';
import 'package:flutter_chat_app/features/chat/presentation/widgets/modern_header.dart';

class StoryScreen extends StatelessWidget {
  const StoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final stories = [
      {'name': 'You', 'isSeen': false},
      {'name': 'Sarah', 'isSeen': true},
      {'name': 'Mike', 'isSeen': false},
      {'name': 'Olivia', 'isSeen': true},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ModernHeader(
              title: "Stories",
              subtitle: "Tap to view recent updates",
              icon: Icons.camera_alt_outlined,
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final story = stories[index];
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: story['isSeen'] as bool
                            ? Colors.grey.shade400
                            : colorScheme.primary,
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: theme.cardColor,
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        story['name'] as String,
                        style: TextStyle(
                          color: colorScheme.onBackground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
