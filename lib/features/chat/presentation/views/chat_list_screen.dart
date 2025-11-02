import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../controllers/chat_list_controller.dart';
import '../widgets/chat_tile.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late ChatListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChatListController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.PROFILE);
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Obx(
        () {
          
          if (controller.isLoading.value && controller.chatRooms.isEmpty) {
            return const LoadingWidget(message: 'Loading chats...');
          }

          
          if (controller.error.value != null && controller.chatRooms.isEmpty) {
            return ErrorDisplayWidget(
              message: controller.error.value!,
              onRetry: () {
                controller.error.value = null;
                controller.refreshChatRooms();
              },
            );
          }

          
          if (controller.chatRooms.isEmpty) {
            return EmptyStateWidget(
              title: 'No chats yet',
              message: 'Start a conversation by adding a friend or creating a new chat.',
              icon: Icons.chat_outlined,
              actionText: 'Find Friends',
              onAction: () {
                
                Get.snackbar(
                  'Coming Soon',
                  'Friend discovery feature coming soon!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary,
                );
              },
            );
          }

          final filteredRooms = controller.filteredChatRooms;

          return RefreshIndicator(
            onRefresh: controller.refreshChatRooms,
            child: Column(
              children: [
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: controller.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search chats...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final chatRoom = filteredRooms[index];

                      return ChatTile(
                        chatRoom: chatRoom,
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.CHAT,
                            arguments: {
                              'chatRoomId': chatRoom.id,
                              'currentUserId': controller.currentUserId,
                              'otherUserId': chatRoom.participants.firstWhere(
                                (id) => id != controller.currentUserId,
                              ),
                              'senderName': chatRoom.otherUserName,
                              'senderPhotoUrl': chatRoom.otherUserPhotoUrl,
                            },
                          );
                        },
                        onLongPress: () {
                          _showChatOptions(context, controller, chatRoom);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
          Get.snackbar(
            'Coming Soon',
            'New chat creation feature coming soon!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
          );
        },
        child: const Icon(Icons.message),
      ),
    );
  }

  void _showChatOptions(
    BuildContext context,
    ChatListController controller,
    ChatRoomEntity chatRoom,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.mic_off),
              title: const Text('Mute'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pin),
              title: const Text('Pin'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                controller.deleteChatRoom(chatRoom.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
