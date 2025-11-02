import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/core/config/app_constants.dart';
import 'package:flutter_chat_app/core/config/app_router.dart';
import 'package:flutter_chat_app/core/di/injector.dart';
import 'package:flutter_chat_app/features/chat/data/models/chat_user.dart';
import 'package:flutter_chat_app/features/chat/data/models/message_model.dart';
import '../bloc/cubit/chat_list_cubit.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => sl<ChatListCubit>()..loadUsers(AppConstants.currentUserId),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _ModernHeader(),
              Expanded(
                child: BlocBuilder<ChatListCubit, ChatListState>(
                  builder: (context, state) {
                    if (state is ChatListLoading) {
                      return _LoadingState();
                    } else if (state is ChatListLoaded) {
                      final users = state.users;

                      if (users.isEmpty) {
                        return _EmptyState();
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<ChatListCubit>().loadUsers(
                            AppConstants.currentUserId,
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return _ModernUserListItem(user: user);
                          },
                        ),
                      );
                    } else if (state is ChatListError) {
                      return _ErrorState(
                        message: state.message,
                        onRetry: () {
                          context.read<ChatListCubit>().loadUsers(
                            AppConstants.currentUserId,
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading conversations...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to start a conversation',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.primary.withOpacity(0.2)
                  : colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.search, color: colorScheme.primary),
              onPressed: () {
                // TODO: Implement search
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with friends',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: isDark ? Colors.red.shade400 : Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "Error loading users",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernUserListItem extends StatelessWidget {
  final ChatUser user;

  const _ModernUserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToChat(context, user),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: (user.isOnline ?? false)
                              ? Colors.green.shade400
                              : Colors.grey.shade300,
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Icon(
                                Icons.person,
                                size: 28,
                                color: Colors.grey.shade500,
                              )
                            : null,
                      ),
                    ),
                    if (user.isOnline ?? false)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green.shade500,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: user.unreadCount > 0
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: Colors.grey.shade900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.lastMessageTime != null)
                            Text(
                              _formatTimestamp(user.lastMessageTime!),
                              style: TextStyle(
                                fontSize: 12,
                                color: user.unreadCount > 0
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade500,
                                fontWeight: user.unreadCount > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: user.isTyping
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 16,
                                        child: _SmallTypingIndicator(),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'typing...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue.shade600,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          user.lastMessage ??
                                              "Start a conversation",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: user.unreadCount > 0
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade600,
                                            fontWeight: user.unreadCount > 0
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            height: 1.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Show message status if last message is from current user
                                      if (user.lastMessageStatus != null) ...[
                                        const SizedBox(width: 4),
                                        _buildMessageStatusIcon(
                                          user.lastMessageStatus!,
                                        ),
                                      ],
                                    ],
                                  ),
                          ),
                          if (user.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 24,
                                minHeight: 24,
                              ),
                              child: Center(
                                child: Text(
                                  user.unreadCount > 99
                                      ? '99+'
                                      : user.unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context, ChatUser user) {
    // You'll need to get the chatId from your repository
    // For now, we'll generate it the same way as in ChatRemoteSource
    final participants = [AppConstants.currentUserId, user.id]..sort();
    final chatId = participants.join('_');

    Navigator.pushNamed(
      context,
      AppRouter.chatScreen,
      arguments: {
        'chatId': chatId,
        'receiverName': user.name,
        'receiverId': user.id,
      },
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey.shade500;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey.shade600;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue.shade600;
        break;
    }

    return Icon(icon, size: 14, color: color);
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return "${time.day}/${time.month}/${time.year}";
    }
  }
}

class _SmallTypingIndicator extends StatefulWidget {
  @override
  State<_SmallTypingIndicator> createState() => _SmallTypingIndicatorState();
}

class _SmallTypingIndicatorState extends State<_SmallTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_controller.value + delay) % 1.0;
            final opacity = (animationValue < 0.5)
                ? animationValue * 2
                : 2 - (animationValue * 2);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.blue[600]?.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
