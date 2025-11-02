import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: controller.senderPhotoUrl != null
                    ? NetworkImage(controller.senderPhotoUrl!)
                    : null,
                child: controller.senderPhotoUrl == null
                    ? Text(
                        (controller.otherUserId ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
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
                      controller.otherUserId ?? 'Chat',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Text(
                      'Active now',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.online,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.error.value != null) {
            return ErrorDisplayWidget(
              message: controller.error.value!,
              onRetry: () => controller.error.value = null,
            );
          }

          if (controller.messages.isEmpty) {
            return EmptyStateWidget(
              title: 'No messages yet',
              message: 'Start a conversation by sending a message',
              icon: Icons.chat_outlined,
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: controller.scrollController,
                  reverse: true,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        controller.messages[controller.messages.length - 1 - index];
                    final isCurrentUser =
                        message.senderId == controller.currentUserId;

                    return MessageBubble(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      onLongPress: () {
                        if (isCurrentUser) {
                          _showMessageOptions(context, controller, message);
                        }
                      },
                    );
                  },
                ),
              ),
              if (controller.isUploading.value)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading ${(controller.uploadProgress.value * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              MessageInput(controller: controller),
            ],
          );
        },
      ),
    );
  }

  void _showMessageOptions(
    BuildContext context,
    ChatController controller,
    var message,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                controller.deleteMessage(message.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
