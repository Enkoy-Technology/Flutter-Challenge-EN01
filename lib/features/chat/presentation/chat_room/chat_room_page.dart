import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/skeleton_widgets.dart';
import '../../chat_controller.dart';
import '../../data/models/message_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/data/models/user_model.dart';

class ChatRoomPage extends ConsumerStatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserPhotoUrl;

  const ChatRoomPage({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserPhotoUrl,
  });

  @override
  ConsumerState<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends ConsumerState<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  UserModel? _otherUser;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOtherUser();
    // Scroll to bottom when chat opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsRead();
      // Delay to ensure messages are loaded
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToBottom(immediately: true);
      });
    });
  }

  Future<void> _loadOtherUser() async {
    try {
      final repository = AuthRepository();
      final user = await repository.getUserById(widget.otherUserId);
      if (mounted) {
        setState(() => _otherUser = user);
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _markMessagesAsRead() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      final repository = ref.read(chatRepositoryProvider);
      await repository.markMessagesAsRead(widget.chatId, currentUserId);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Stop typing indicator when leaving
    if (_isTyping) {
      _stopTyping();
    }
    super.dispose();
  }

  void _scrollToBottom({bool immediately = false}) {
    if (_scrollController.hasClients) {
      if (immediately) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      // Also scroll after a delay to account for images loading
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_scrollController.hasClients && mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _stopTyping();

    try {
      final repository = ref.read(chatRepositoryProvider);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        await repository.sendMessage(
          chatId: widget.chatId,
          senderId: currentUserId,
          text: text,
        );
        // Scroll will be handled by the callback
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  void _startTyping() {
    if (!_isTyping) {
      _isTyping = true;
      final repository = ref.read(chatRepositoryProvider);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        repository.setTypingIndicator(widget.chatId, currentUserId, true);
      }
    }
  }

  void _stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      final repository = ref.read(chatRepositoryProvider);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        repository.setTypingIndicator(widget.chatId, currentUserId, false);
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final repository = ref.read(chatRepositoryProvider);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId != null) {
        await repository.sendImageMessage(
          chatId: widget.chatId,
          senderId: currentUserId,
          imagePath: image.path,
        );
        // Scroll will be handled by the callback after image loads
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send image: $e')),
        );
      }
    }
  }

  void _showImageFullScreen(String imageUrl) {
    final colorScheme = Theme.of(context).colorScheme;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            iconTheme: IconThemeData(color: colorScheme.onSurface),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Icon(
                    Icons.error,
                    color: colorScheme.error,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final typingAsync = ref.watch(
      typingIndicatorProvider(
        TypingIndicatorParams(
          chatId: widget.chatId,
          currentUserId: currentUserId,
          otherUserId: widget.otherUserId,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.otherUserPhotoUrl != null
                  ? CachedNetworkImageProvider(widget.otherUserPhotoUrl!)
                  : null,
              child: widget.otherUserPhotoUrl == null
                  ? Text(
                      widget.otherUserName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 16),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUserName),
                  if (_otherUser != null)
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _otherUser!.isOnline
                                ? colorScheme.tertiary
                                : colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _otherUser!.isOnline
                              ? 'Online'
                              : DateFormatter.formatLastSeen(_otherUser!.lastSeen),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
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
      body: SafeArea(
        child: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                // Check if new messages were added (including images)
                final hasNewMessages = messages.length > _previousMessageCount;
                final isInitialLoad = _previousMessageCount == 0 && messages.isNotEmpty;
                
                if (hasNewMessages || isInitialLoad) {
                  _previousMessageCount = messages.length;
                  
                  // For initial load, scroll to bottom immediately
                  if (isInitialLoad) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom(immediately: true);
                      // Scroll again after images load
                      Future.delayed(const Duration(milliseconds: 800), () {
                        if (mounted) _scrollToBottom();
                      });
                    });
                  } else {
                    // For new messages, scroll smoothly
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
                    // Scroll again after images load (with delay)
                    Future.delayed(const Duration(milliseconds: 1000), () {
                      if (mounted) _scrollToBottom();
                    });
                  }
                }
                
                // Show typing indicator at the end if active
                final showTyping = typingAsync.value ?? false;
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: false, // Normal order: oldest at top, newest at bottom
                  itemCount: messages.length + (showTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show typing indicator at the last index if active
                    if (showTyping && index == messages.length) {
                      return _TypingIndicatorWidget();
                    }
                    // Show message at its index
                    return _MessageBubble(
                      message: messages[index],
                      isMe: messages[index].senderId == currentUserId,
                      onImageTap: _showImageFullScreen,
                    );
                  },
                );
              },
              loading: () => const ChatMessagesSkeleton(),
              error: (error, stack) => ErrorDisplayWidget(
                message: 'Error loading messages: $error',
                onRetry: () => ref.invalidate(messagesProvider(widget.chatId)),
              ),
            ),
          ),
          _MessageInputField(
            messageController: _messageController,
            onSend: () async {
              await _sendMessage();
              // Scroll after sending
              Future.delayed(const Duration(milliseconds: 100), () {
                _scrollToBottom();
              });
            },
            onTyping: _startTyping,
            onImagePick: () async {
              await _pickAndSendImage();
              // Scroll after image is sent (it will load asynchronously)
              Future.delayed(const Duration(milliseconds: 800), () {
                _scrollToBottom();
              });
            },
          ),
        ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final Function(String) onImageTap;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.person,
                size: 20,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe
                    ? null
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? colorScheme.primary.withOpacity(0.3)
                        : colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
                border: isMe
                    ? null
                    : Border.all(
                        color: colorScheme.outline.withOpacity(0.5),
                        width: 0.5,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.type == AppConstants.messageTypeImage &&
                      message.mediaUrl != null)
                    GestureDetector(
                      onTap: () {
                        // Open image in full screen
                        onImageTap(message.mediaUrl!);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: message.mediaUrl!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 200,
                            height: 200,
                            color: isMe
                                ? colorScheme.onPrimary.withOpacity(0.2)
                                : colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: isMe 
                                    ? colorScheme.onPrimary.withOpacity(0.7) 
                                    : colorScheme.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 200,
                            height: 200,
                            color: isMe
                                ? colorScheme.onPrimary.withOpacity(0.2)
                                : colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.error,
                              color: isMe 
                                  ? colorScheme.onPrimary.withOpacity(0.7) 
                                  : colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          fadeInDuration: const Duration(milliseconds: 300),
                          memCacheWidth: 400, // Optimize memory
                        ),
                      ),
                    )
                  else
                    Text(
                      message.text,
                      style: TextStyle(
                        color: isMe
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormatter.formatMessageTime(message.timestamp),
                        style: TextStyle(
                          color: isMe
                              ? colorScheme.onPrimary.withOpacity(0.8)
                              : colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 16,
                          color: message.isRead
                              ? colorScheme.onPrimary
                              : colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingIndicatorWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              Icons.person,
              size: 20,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 4),
                _TypingDot(delay: 200),
                const SizedBox(width: 4),
                _TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(0.54),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _MessageInputField extends StatefulWidget {
  final TextEditingController messageController;
  final VoidCallback onSend;
  final VoidCallback onTyping;
  final VoidCallback onImagePick;

  const _MessageInputField({
    required this.messageController,
    required this.onSend,
    required this.onTyping,
    required this.onImagePick,
  });

  @override
  State<_MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<_MessageInputField> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: widget.onImagePick,
          ),
          Expanded(
            child: TextField(
              controller: widget.messageController,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => widget.onTyping(),
              onSubmitted: (_) => widget.onSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: widget.onSend,
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}


