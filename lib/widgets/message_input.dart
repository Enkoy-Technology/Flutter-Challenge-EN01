import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_service_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/fcm_notification_service.dart';
import '../theme/app_colors.dart';

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

  Future<void> submit() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
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
      );
      controller.clear();

      final recipientDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientId)
          .get();
      final fcmToken = recipientDoc['fcmToken'];

      if (fcmToken != null && fcmToken != "") {
        final fcmService = FcmNotificationService();
        await fcmService.sendNotification(
          fcmToken: fcmToken,
          title: 'New message from ${widget.currentUserName}',
          body: text,
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
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_outlined,
                        color: AppColors.greyTextDark),
                    onPressed: () {},
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
