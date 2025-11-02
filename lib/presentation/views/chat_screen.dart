import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/app_user.dart';
import '../controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatelessWidget {
  final AuthController _authController = Get.find();

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppUser otherUser = Get.arguments as AppUser;

    final ChatController controller = Get.put(
      ChatController(otherUser: otherUser),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ProfileAvatar(user: otherUser, radius: 20),
            const SizedBox(width: 12),
            Text(otherUser.fullName),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                itemCount: controller.messages.value.length,
                itemBuilder: (context, index) {
                  final message = controller.messages.value[index];
                  final isMe =
                      message.senderId ==
                      _authController.currentUser.value?.uid;
                  return MessageBubble(message: message, isMe: isMe);
                },
              );
            }),
          ),
          Obx(
            () => controller.isOtherUserTyping.value
                ? const TypingIndicator()
                : const SizedBox.shrink(),
          ),
          ChatInput(
            onSend: (text) {
              controller.sendMessage(
                senderId: _authController.currentUser.value!.uid,
                senderName: _authController.currentUser.value!.fullName,
                text: text,
              );
            },
            onTyping: controller.onUserTyping,
          ),
        ],
      ),
    );
  }
}
