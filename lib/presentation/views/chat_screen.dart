
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends GetView<ChatController> {
  final AuthController _authController = Get.find();

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
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
                  final isMe = message.senderId == _authController.currentUser.value?.uid;
                  return MessageBubble(
                    message: message,
                    isMe: isMe,
                  );
                },
              );
            }),
          ),
          ChatInput(
            onSend: (text) {
              controller.sendMessage(
                senderId: _authController.currentUser.value!.uid,
                senderName: _authController.currentUser.value!.fullName,
                text: text,
              );
            },
            onPickImage: (image) {
              controller.sendMessage(
                senderId: _authController.currentUser.value!.uid,
                senderName: _authController.currentUser.value!.fullName,
                mediaFile: image,
              );
            },
          ),
        ],
      ),
    );
  }
}
