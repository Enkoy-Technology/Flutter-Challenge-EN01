import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../../domain/models/app_user.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/animated_list_item.dart';

class ChatListScreen extends GetView<AuthController> {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Obx(() {
              final currentUser = controller.currentUser.value;
              if (currentUser == null) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => Get.toNamed('/profile'),
                child: ProfileAvatar(user: currentUser, radius: 18),
              );
            }),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.currentUser.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<QuerySnapshot>(
          // Use the new stream of sorted chats
          stream: userController.getChatsStream(
            controller.currentUser.value!.uid,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint('Firestore Stream Error: ${snapshot.error}');
              return Center(
                child: Text('An error occurred. Check debug console.'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No chats yet. Start a conversation!'),
              );
            }

            final chatDocs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: chatDocs.length,
              itemBuilder: (context, index) {
                final chatDoc = chatDocs[index];
                final lastMessageData =
                    chatDoc['lastMessage'] as Map<String, dynamic>;
                final members = List<String>.from(chatDoc['members']);
                final otherUserId = members.firstWhere(
                  (id) => id != controller.currentUser.value!.uid,
                  orElse: () => '',
                );

                return AnimatedListItem(
                  index: index,
                  child: _ChatListItem(
                    otherUserId: otherUserId,
                    lastMessageData: lastMessageData,
                  ),
                );
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/new_chat'),
        child: const Icon(Icons.add_comment_rounded),
        tooltip: 'New Chat',
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final String otherUserId;
  final Map<String, dynamic> lastMessageData;

  const _ChatListItem({
    required this.otherUserId,
    required this.lastMessageData,
  });

  @override
  Widget build(BuildContext context) {
    final userFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserId)
        .get();

    return FutureBuilder<DocumentSnapshot>(
      future: userFuture,
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return Opacity(
            opacity: 0.5,
            child: const ListTile(
              leading: CircleAvatar(radius: 28),
              title: Text('Loading...'),
            ),
          );
        }

        final otherUser = AppUser.fromFirestore(userSnapshot.data!);
        final lastMessageText = lastMessageData['text'] as String? ?? '';
        final lastMessageSenderId =
            lastMessageData['senderId'] as String? ?? '';
        final isSeen = lastMessageData['isSeen'] as bool? ?? true;
        final currentUserId = Get.find<AuthController>().currentUser.value!.uid;
        final hasUnread = lastMessageSenderId != currentUserId && !isSeen;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface.withOpacity(0.8),
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            leading: ProfileAvatar(user: otherUser, radius: 28),
            title: Text(
              otherUser.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              lastMessageText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: hasUnread
                ? CircleAvatar(
                    radius: 5,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () => Get.toNamed('/chat', arguments: otherUser),
          ),
        );
      },
    );
  }
}
