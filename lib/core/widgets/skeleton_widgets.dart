import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Base shimmer widget
class _BaseShimmer extends StatelessWidget {
  final Widget child;

  const _BaseShimmer({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark 
          ? colorScheme.surfaceContainerHighest 
          : colorScheme.surfaceContainerLowest,
      highlightColor: isDark 
          ? colorScheme.surfaceContainer 
          : colorScheme.surfaceContainerLowest.withOpacity(0.5),
      child: child,
    );
  }
}

// Chat list skeleton
class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark 
        ? colorScheme.surfaceContainerHighest 
        : colorScheme.surfaceContainerLowest;
    
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 8,
      itemBuilder: (context, index) {
        return _BaseShimmer(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: baseColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: 150,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 14,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 12,
                            width: 50,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Users list skeleton
class UsersListSkeleton extends StatelessWidget {
  const UsersListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final baseColor = isDark 
            ? colorScheme.surfaceContainerHighest 
            : colorScheme.surfaceContainerLowest;
        
        return _BaseShimmer(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: baseColor,
              ),
              title: Container(
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: baseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: baseColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Profile skeleton
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark 
        ? colorScheme.surfaceContainerHighest 
        : colorScheme.surfaceContainerLowest;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _BaseShimmer(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile picture skeleton
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: baseColor,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: baseColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Name field skeleton
            Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            // Email field skeleton
            Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            // Status skeleton
            Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 32),
            // Sign out button skeleton
            Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chat room messages skeleton
class ChatMessagesSkeleton extends StatefulWidget {
  const ChatMessagesSkeleton({super.key});

  @override
  State<ChatMessagesSkeleton> createState() => _ChatMessagesSkeletonState();
}

class _ChatMessagesSkeletonState extends State<ChatMessagesSkeleton> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when skeleton loads (same as real chat)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients && mounted) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark 
        ? colorScheme.surfaceContainerHighest 
        : colorScheme.surfaceContainerLowest;
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        // Alternate between sender positions for more realistic look
        final isMe = index % 2 == 0;
        
        // Vary message widths for realism
        final messageWidth = 150.0 + (index % 3) * 50.0;
        final messageHeight = 50.0 + (index % 2) * 20.0;
        
        return _BaseShimmer(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe) ...[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: baseColor,
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  width: messageWidth,
                  height: messageHeight,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                if (isMe) const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

