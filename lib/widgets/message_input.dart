import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/fcm_notification_service.dart';
import '../theme/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';


class MessageInput extends ConsumerStatefulWidget {
  final String chatId;
  final String currentUserId;
  final String currentUserName;
  

  const MessageInput({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  bool showActions = false;

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  final ImagePicker _picker = ImagePicker();
  File? _selectedMedia;


  Future<void> _pickMedia(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _selectedMedia = File(pickedFile.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick media: $e')),
      );
    }
  }



  Future<void> submit() async {
    final text = controller.text.trim();

    if (text.isEmpty && _selectedMedia == null) return;

    String? mediaUrl;

    if (_selectedMedia != null) {
      // Upload media
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_media')
          .child('${DateTime.now().millisecondsSinceEpoch}');
      await storageRef.putFile(_selectedMedia!);
      mediaUrl = await storageRef.getDownloadURL();
    }

    try {
      final chatService = ref.read(chatServiceProvider);
      final chatRef =
          FirebaseFirestore.instance.collection('chats').doc(widget.chatId);
      final chatSnap = await chatRef.get();
      final participants = (chatSnap['participants'] as List).cast<String>();
      final recipientId =
          participants.firstWhere((id) => id != widget.currentUserId);

      await chatService.sendChatMessage(
        widget.chatId,
        widget.currentUserId,
        widget.currentUserName,
        text,
        recipientId,
        mediaUrl: mediaUrl,
      );

      controller.clear();
      setState(() {
        _selectedMedia = null;
      });

      final recipientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientId)
          .get();
      final fcmToken = recipientDoc['fcmToken'];
      if (fcmToken != null && fcmToken != '') {
        final fcmService = FcmNotificationService();
        await fcmService.sendNotification(
          fcmToken: fcmToken,
          title: 'New message from ${widget.currentUserName}',
          body: text.isEmpty ? 'Sent a media file' : text,
          chatId: widget.chatId,
          chatName: widget.currentUserName,
          senderId: widget.currentUserId,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  showActions
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: AppColors.greyTextDark,
                ),
                onPressed: () {
                  setState(() => showActions = !showActions);
                },
              ),
              if (_selectedMedia != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedMedia!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: IconButton(
                          icon: const Icon(Icons.cancel,
                              color: Colors.red, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedMedia = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightGreyBackground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: controller,

                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const DarkColors().textSecondary
                            : const LightColors().textSecondary,
                      ),
                    ),
                    style:  TextStyle(fontSize: 15, color: Theme.of(context).brightness == Brightness.dark
                          ? const DarkColors().textSecondary
                          : const LightColors().textSecondary,
                    ),
                    onSubmitted: (_) => submit(),
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryBlue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: AppColors.white, size: 20),
                    onPressed: submit,
                  ),
                ),
              ),
            ],
          ),
          if (showActions)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined,
                        color: AppColors.greyTextDark),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic, color: Color(0xFF757575)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: AppColors.greyTextDark),
                    onPressed: () => _pickMedia(ImageSource.camera),
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_outlined,
                        color: AppColors.greyTextDark),
                    onPressed: () => _pickMedia(ImageSource.gallery),
                  ),

                  IconButton(
                    icon:
                        const Icon(Icons.add_circle, color: Color(0xFF2196F3)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
