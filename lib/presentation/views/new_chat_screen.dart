import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/profile_avatar.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final UserController userController = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: StreamBuilder<QuerySnapshot>(
        stream: userController.getChatsStream(
          authController.currentUser.value!.uid,
        ),
        builder: (context, chatSnapshot) {
          return Obx(() {
            if (userController.users.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final existingChatPartnerIds =
                chatSnapshot.data?.docs.map((doc) {
                  final members = List<String>.from(doc['members']);
                  return members.firstWhere(
                    (id) => id != authController.currentUser.value!.uid,
                    orElse: () => '',
                  );
                }).toSet() ??
                {};

            final availableUsers = userController.users.where((user) {
              final isCurrentUser =
                  user.uid == authController.currentUser.value?.uid;
              final hasExistingChat = existingChatPartnerIds.contains(user.uid);
              return !isCurrentUser && !hasExistingChat;
            }).toList();

            if (availableUsers.isEmpty) {
              return const Center(child: Text('No new users to chat with.'));
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: availableUsers.length,
              separatorBuilder: (context, index) =>
                  const Divider(indent: 72, endIndent: 16, height: 1),
              itemBuilder: (context, index) {
                final user = availableUsers[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  leading: ProfileAvatar(user: user, radius: 28),
                  title: Text(
                    user.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Get.offNamed('/chat', arguments: user);
                  },
                );
              },
            );
          });
        },
      ),
    );
  }
}
