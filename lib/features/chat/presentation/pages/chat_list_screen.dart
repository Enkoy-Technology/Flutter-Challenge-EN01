import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/core/config/app_constants.dart';
import 'package:flutter_chat_app/core/config/app_router.dart';
import 'package:flutter_chat_app/core/di/injector.dart';
import 'package:flutter_chat_app/features/chat/data/models/chat_user.dart';
import '../bloc/cubit/chat_list_cubit.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatListCubit>()..loadUsers(AppConstants.currentUserId),
      child: Scaffold(
        appBar: AppBar(title: const Text("Chats")),
        body: BlocBuilder<ChatListCubit, ChatListState>(
          builder: (context, state) {
            if (state is ChatListLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ChatListLoaded) {
              final users = state.users;

              if (users.isEmpty) {
                return const Center(
                  child: Text(
                    "No users found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];

                  return _UserListItem(user: user);
                },
              );
            } else if (state is ChatListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Error loading users",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ChatListCubit>().loadUsers(
                          AppConstants.currentUserId,
                        );
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final ChatUser user;

  const _UserListItem({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, size: 24)
                  : null,
            ),
            if (user.isOnline ?? false)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: user.isTyping
            ? Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 16,
                    child: _SmallTypingIndicator(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'typing...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              )
            : user.lastMessage != null
            ? Text(
                user.lastMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: user.unreadCount > 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : const Text(
                "Start a conversation",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.lastMessageTime != null)
              Text(
                _formatTimestamp(user.lastMessageTime!),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            if (user.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  user.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => _navigateToChat(context, user),
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
