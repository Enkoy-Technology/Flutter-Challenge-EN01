import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/chat_utils.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/skeleton_widgets.dart';
import '../../chat_controller.dart';
import '../../data/models/chat_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../home/presentation/home_page.dart';
import '../chat_room/chat_room_page.dart';

class ChatListPage extends ConsumerWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsProvider);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'How to Start a Chat',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Go to the "Users" tab to browse all users\n'
                        '2. Use the search bar in Users tab to find specific users\n'
                        '3. Tap on any user to start a conversation',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to Users tab
                          ref.read(currentIndexProvider.notifier).state = 1;
                        },
                        icon: const Icon(Icons.people_outline),
                        label: const Text('Browse Users'),
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
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No chats yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatListItem(
                chat: chat,
                currentUserId: currentUser?.uid ?? '',
              );
            },
          );
        },
        loading: () => const ChatListSkeleton(),
        error: (error, stack) => ErrorDisplayWidget(
          message: 'Error loading chats: $error',
          onRetry: () => ref.invalidate(chatsProvider),
        ),
      ),
    );
  }
}

class _ChatListItem extends ConsumerStatefulWidget {
  final ChatModel chat;
  final String currentUserId;

  const _ChatListItem({
    required this.chat,
    required this.currentUserId,
  });

  @override
  ConsumerState<_ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends ConsumerState<_ChatListItem> {
  UserModel? _otherUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOtherUser();
  }

  Future<void> _loadOtherUser() async {
    final otherUserId =
        ChatUtils.getOtherUserId(widget.chat.id, widget.currentUserId);
    if (otherUserId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final repository = AuthRepository();
      final user = await repository.getUserById(otherUserId);
      if (mounted) {
        setState(() {
          _otherUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show skeleton instead of just spinner
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;
      final baseColor = isDark 
          ? colorScheme.surfaceContainerHighest 
          : colorScheme.surfaceContainerLowest;
      final highlightColor = isDark 
          ? colorScheme.surfaceContainer 
          : colorScheme.surfaceContainerLowest.withOpacity(0.5);
      return Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: baseColor,
          ),
          title: Container(
            height: 16,
            width: 150,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              height: 14,
              width: 200,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    }

    final otherUserId =
        ChatUtils.getOtherUserId(widget.chat.id, widget.currentUserId);
    final isUnread = widget.chat.unreadCount > 0 &&
        widget.chat.lastMessageSenderId != widget.currentUserId;

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundImage: _otherUser?.photoUrl != null
            ? CachedNetworkImageProvider(_otherUser!.photoUrl!)
            : null,
        child: _otherUser?.photoUrl == null
            ? Text(
                _otherUser?.name.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(fontSize: 20),
              )
            : null,
      ),
      title: Text(
        _otherUser?.name ?? 'Unknown User',
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              widget.chat.lastMessage ?? 'No messages yet',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                color: isUnread 
                    ? Theme.of(context).colorScheme.onSurface 
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          if (widget.chat.lastMessageTime != null) ...[
            const SizedBox(width: 8),
            Text(
              DateFormatter.formatMessageTime(widget.chat.lastMessageTime!),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
      trailing: isUnread
          ? Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                widget.chat.unreadCount > 9
                    ? '9+'
                    : widget.chat.unreadCount.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(
              chatId: widget.chat.id,
              otherUserId: otherUserId,
              otherUserName: _otherUser?.name ?? 'Unknown User',
              otherUserPhotoUrl: _otherUser?.photoUrl,
            ),
          ),
        );
      },
    );
  }
}

