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
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null
              ? const Icon(Icons.person, size: 24)
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: user.lastMessage != null
            ? Text(
                user.lastMessage!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : const Text(
                "Start a conversation",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
        trailing: user.lastMessageTime != null
            ? Text(
                _formatTimestamp(user.lastMessageTime!),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              )
            : null,
        onTap: () {
          _navigateToChat(context, user);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
