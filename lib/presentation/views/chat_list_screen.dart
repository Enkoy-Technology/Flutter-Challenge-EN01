
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../widgets/profile_avatar.dart';

class ChatListScreen extends GetView<AuthController> {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => controller.signOut(),
          )
        ],
      ),
      body: StreamBuilder(
        stream: userController.usersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: ProfileAvatar(imageUrl: user.profileImageUrl),
                title: Text(user.name),
                subtitle: const Text('Last message...'),
                onTap: () => Get.toNamed('/chat', arguments: user.id),
              );
            },
          );
        },
      ),
    );
  }
}
