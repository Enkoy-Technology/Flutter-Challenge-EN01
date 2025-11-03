import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:record/record.dart';
import '../../../../../main.dart' as app;
import '../../../data/models/user_model.dart';
import '../../../data/repositories/message_repository.dart';
import '../../bloc/chat_room/chat_room_bloc.dart';
import '../../bloc/chat_room/chat_room_event.dart';
import '../../bloc/chat_room/chat_room_state.dart';
import '../../widgets/message_bubble.dart';

class ChatRoomPage extends StatefulWidget {
  final String chatId;
  final UserModel otherUser;

  const ChatRoomPage({
    super.key,
    required this.chatId,
    required this.otherUser,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late ChatRoomBloc _chatRoomBloc;
  bool _showEmojiPicker = false;
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;

  // Image preview state
  XFile? _selectedImage;
  bool _isSendingImage = false;

  @override
  void initState() {
    super.initState();
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;
    _chatRoomBloc = ChatRoomBloc(
      MessageRepository(Supabase.instance.client, app.cacheService),
      currentUserId,
    );
    _chatRoomBloc.add(ChatRoomMessagesSubscriptionRequested(widget.chatId));
    _chatRoomBloc.add(ChatRoomMarkMessagesAsRead(widget.chatId));

    // Listen to text changes to update send button icon
    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatRoomBloc.close();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isNotEmpty) {
      _chatRoomBloc.add(
        ChatRoomMessageSendRequested(chatId: widget.chatId, content: content),
      );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _showEmojiPicker = false; // Hide emoji picker when image is selected
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _showEmojiPicker = false; // Hide emoji picker when image is selected
      });
    }
  }

  void _clearSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _sendImageMessage() async {
    if (_selectedImage == null || _isSendingImage) return;

    setState(() {
      _isSendingImage = true;
    });

    try {
      _chatRoomBloc.add(
        ChatRoomMediaMessageSendRequested(
          chatId: widget.chatId,
          filePath: _selectedImage!.path,
          messageType: 'image',
        ),
      );

      setState(() {
        _selectedImage = null;
        _isSendingImage = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isSendingImage = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send image: $e')));
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        // Start recording
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: '${DateTime.now().millisecondsSinceEpoch}.m4a',
        );
        setState(() {
          _isRecording = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = path;
      });

      if (path != null && mounted) {
        // Show dialog to send or cancel
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Send Voice Message?'),
            content: const Text('Do you want to send this voice message?'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() => _recordingPath = null);
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Send voice message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Voice message sending coming soon!'),
                    ),
                  );
                  setState(() => _recordingPath = null);
                  Navigator.pop(context);
                },
                child: const Text('Send'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isRecording = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.pink,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Document sharing coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text(
          'Are you sure you want to clear all messages in this chat? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Clear chat feature coming soon!'),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showUserProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: widget.otherUser.avatarUrl != null
                    ? NetworkImage(widget.otherUser.avatarUrl!)
                    : null,
                child: widget.otherUser.avatarUrl == null
                    ? Text(
                        widget.otherUser.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              // Display Name
              Text(
                widget.otherUser.displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Email
              Text(
                widget.otherUser.email,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              // Online Status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.otherUser.isOnline
                          ? Colors.green
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.otherUser.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: widget.otherUser.isOnline
                          ? Colors.green
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleMuteNotifications(BuildContext context) {
    // TODO: Implement actual mute/unmute logic with database
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mute Notifications'),
        content: const Text('Do you want to mute notifications for this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications muted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Mute'),
          ),
        ],
      ),
    );
  }

  void _showBlockUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: Text(
          'Are you sure you want to block ${widget.otherUser.displayName}? You will no longer receive messages from this user.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual block logic with database
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${widget.otherUser.displayName} has been blocked',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
              // Navigate back to chat list
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _startVoiceCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: widget.otherUser.avatarUrl != null
                    ? NetworkImage(widget.otherUser.avatarUrl!)
                    : null,
                child: widget.otherUser.avatarUrl == null
                    ? Text(
                        widget.otherUser.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                widget.otherUser.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Call Status
              const Text(
                'Calling...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              // Call Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute Button
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[300],
                        child: IconButton(
                          icon: const Icon(
                            Icons.mic_off,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mute toggled'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Mute', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  // End Call Button
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Call ended'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('End', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  // Speaker Button
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[300],
                        child: IconButton(
                          icon: const Icon(
                            Icons.volume_up,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Speaker toggled'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Speaker', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startVideoCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: widget.otherUser.avatarUrl != null
                    ? NetworkImage(widget.otherUser.avatarUrl!)
                    : null,
                child: widget.otherUser.avatarUrl == null
                    ? Text(
                        widget.otherUser.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                widget.otherUser.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Call Status
              const Text(
                'Video calling...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              // Call Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Toggle
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[300],
                        child: IconButton(
                          icon: const Icon(
                            Icons.videocam_off,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Camera toggled'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Camera', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  // End Call Button
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Video call ended'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('End', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  // Mute Button
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey[300],
                        child: IconButton(
                          icon: const Icon(
                            Icons.mic_off,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mute toggled'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Mute', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;

    return BlocProvider.value(
      value: _chatRoomBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: widget.otherUser.avatarUrl != null
                    ? NetworkImage(widget.otherUser.avatarUrl!)
                    : null,
                child: widget.otherUser.avatarUrl == null
                    ? Text(
                        widget.otherUser.displayName
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUser.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.otherUser.isOnline)
                      const Text(
                        'Online',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: () => _startVideoCall(context),
            ),
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () => _startVoiceCall(context),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'view_profile':
                    _showUserProfile(context);
                    break;
                  case 'mute':
                    _toggleMuteNotifications(context);
                    break;
                  case 'clear_chat':
                    _showClearChatDialog(context);
                    break;
                  case 'block':
                    _showBlockUserDialog(context);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view_profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 20),
                      SizedBox(width: 12),
                      Text('View Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'mute',
                  child: Row(
                    children: [
                      Icon(Icons.notifications_off, size: 20),
                      SizedBox(width: 12),
                      Text('Mute Notifications'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_chat',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, size: 20),
                      SizedBox(width: 12),
                      Text('Clear Chat'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'block',
                  child: Row(
                    children: [
                      Icon(Icons.block, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Block User', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Messages List
            Expanded(
              child: BlocConsumer<ChatRoomBloc, ChatRoomState>(
                listener: (context, state) {
                  if (state is ChatRoomLoaded) {
                    _scrollToBottom();
                    _chatRoomBloc.add(
                      ChatRoomMarkMessagesAsRead(widget.chatId),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ChatRoomLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatRoomError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading messages',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ChatRoomEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Send a message to start the conversation',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ChatRoomLoaded ||
                      state is ChatRoomSendingMessage) {
                    final messages = state is ChatRoomLoaded
                        ? state.messages
                        : (state as ChatRoomSendingMessage).messages;

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUserId;
                        final showAvatar =
                            index == messages.length - 1 ||
                            messages[index + 1].senderId != message.senderId;

                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          showAvatar: showAvatar,
                          otherUserAvatar: widget.otherUser.avatarUrl,
                          otherUserName: widget.otherUser.displayName,
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),

            // Image Preview (Telegram-style)
            if (_selectedImage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image preview thumbnail
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedImage!.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Remove button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _clearSelectedImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Image info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap send to share',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Send button
                    if (!_isSendingImage)
                      IconButton(
                        onPressed: _sendImageMessage,
                        icon: const Icon(Icons.send),
                        color: const Color(0xFF6C5CE7),
                        iconSize: 28,
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
              ),

            // Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment button
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      _showAttachmentOptions(context);
                    },
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  // Text input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          // Emoji button
                          IconButton(
                            icon: Icon(
                              _showEmojiPicker
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _showEmojiPicker = !_showEmojiPicker;
                              });
                              if (_showEmojiPicker) {
                                // Hide keyboard when showing emoji picker
                                FocusScope.of(context).unfocus();
                              }
                            },
                            color: Colors.grey[600],
                            iconSize: 22,
                          ),
                          // Text field
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Message...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          // Camera button
                          IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () {
                              _pickImageFromCamera();
                            },
                            color: Colors.grey[600],
                            iconSize: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send or Voice button
                  CircleAvatar(
                    backgroundColor: _isRecording
                        ? Colors.red
                        : (_selectedImage != null
                              ? const Color(0xFF6C5CE7)
                              : Theme.of(context).colorScheme.primary),
                    child: IconButton(
                      icon: Icon(
                        _isRecording
                            ? Icons.stop
                            : (_selectedImage != null
                                  ? Icons.send
                                  : (_messageController.text.trim().isEmpty
                                        ? Icons.mic
                                        : Icons.send)),
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        if (_isRecording) {
                          await _stopRecording();
                        } else if (_selectedImage != null) {
                          await _sendImageMessage();
                        } else if (_messageController.text.trim().isEmpty) {
                          await _startRecording();
                        } else {
                          _sendMessage();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Emoji Picker
            if (_showEmojiPicker)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _messageController.text += emoji.emoji;
                    // Keep cursor at end
                    _messageController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _messageController.text.length),
                    );
                  },
                  config: const Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      emojiSizeMax: 28,
                      backgroundColor: Color(0xFFF2F2F2),
                      columns: 7,
                      buttonMode: ButtonMode.MATERIAL,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
