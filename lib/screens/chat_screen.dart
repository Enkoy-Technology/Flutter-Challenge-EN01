import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/current_chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../providers/chat_service_provider.dart';
import '../services/chat_list_service.dart';
import 'profile_screen.dart';
import '../theme/app_colors.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String chatName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final scrollController = ScrollController();
  int? _previousMessageCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentChatProvider.notifier).state = widget.chatId;
      _markMessagesAsDelivered();
      _markMessagesAsSeen();
      _resetUnreadCount();
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom(animate: false);
      });
    });
  }

  @override
  void deactivate() {
    Future(() {
      try {
        ref.read(currentChatProvider.notifier).state = null;
      } catch (e) {
        debugPrint('Error deactivating chat screen: $e');
      }
    });
    super.deactivate();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _markMessagesAsDelivered() {
    final authState = ref.read(authStateProvider);
    final currentUser = authState.valueOrNull;

    if (currentUser == null) return;

    final chatService = ref.read(chatServiceProvider);

    chatService.markMessagesAsDelivered(widget.chatId, currentUser.id);
  }

  void _markMessagesAsSeen() {
    final authState = ref.read(authStateProvider);
    final currentUser = authState.valueOrNull;

    if (currentUser == null) return;

    final chatService = ref.read(chatServiceProvider);

    chatService.markMessagesAsSeen(widget.chatId, currentUser.id);
  }

  void _resetUnreadCount() {
    final authState = ref.read(authStateProvider);
    final currentUser = authState.valueOrNull;

    if (currentUser == null) return;

    final chatListService = ChatListService();
    chatListService.resetUnreadCount(widget.chatId, currentUser.id);
  }

  void _scrollToBottom({bool animate = true}) {
    if (scrollController.hasClients) {
      if (animate) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider(widget.chatId));
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.valueOrNull;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = Theme.of(context).colorScheme.surface;
    final onBackground = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGradientStart,
                AppColors.primaryGradientEnd,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: isDark
                          ? const DarkColors().textOnPrimary
                          : const LightColors().textOnPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Builder(
                  builder: (context) {
                    String? chatPartnerId;
                    if (currentUser != null) {
                      chatPartnerId =
                          widget.chatId.split('-').first == currentUser.id
                              ? widget.chatId.split('-').last
                              : widget.chatId.split('-').first;
                    }
                    return GestureDetector(
                      onTap: chatPartnerId != null
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProfileScreen(userId: chatPartnerId!),
                                ),
                              );
                            }
                          : null,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: isDark
                                ? const DarkColors().avatarBackground
                                : const LightColors().avatarBackground,
                            child: Text(
                              widget.chatName.isNotEmpty
                                  ? widget.chatName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: isDark
                                    ? const DarkColors().avatarBorder
                                    : const LightColors().avatarBorder,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (chatPartnerId != null)
                            StreamBuilder<
                                DocumentSnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(chatPartnerId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return const SizedBox.shrink();
                                }
                                final data = snapshot.data!.data();
                                final isOnline = data?['isOnline'] == true;
                                return Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: isOnline
                                          ? isDark
                                              ? const DarkColors().online
                                              : const LightColors().online
                                          : isDark
                                              ? const DarkColors().offline
                                              : const LightColors().offline,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: isDark
                                              ? const DarkColors().avatarBorder
                                              : const LightColors()
                                                  .avatarBorder,
                                          width: 2),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.chatName,
                    style: TextStyle(
                      color: isDark
                          ? const DarkColors().textOnPrimary
                          : const LightColors().textOnPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: background,
        child: Column(
          children: [
            Expanded(
              child: chat.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48,
                          color: isDark
                              ? const DarkColors().error
                              : const LightColors().error),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading messages: $e',
                        style: TextStyle(
                            color: isDark
                                ? const DarkColors().error
                                : const LightColors().error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                data: (messages) {
                  final messageCount = messages.length;
                  final hasNewMessages = _previousMessageCount != null &&
                      messageCount > _previousMessageCount!;
                  _previousMessageCount = messageCount;
                  if (hasNewMessages) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom(animate: true);
                    });
                  }
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 64,
                              color: isDark
                                  ? const DarkColors().textTertiary
                                  : const LightColors().textTertiary),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet\nStart the conversation!',
                            style: TextStyle(color: onBackground, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final isMe = m.sender == currentUser?.name ||
                          m.senderId == currentUser?.id;
                      return ChatBubble(message: m, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            MessageInput(
              chatId: widget.chatId,
              currentUserId: currentUser?.id ?? '',
              currentUserName: currentUser?.name ?? 'User',
            ),
          ],
        ),
      ),
    );
  }
}
