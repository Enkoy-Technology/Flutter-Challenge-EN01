import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';
import '../services/chat_list_service.dart';
import '../models/user_model.dart';
import '../screens/chat_screen.dart';
import '../theme/app_colors.dart';

class UserListDialog extends ConsumerStatefulWidget {
  const UserListDialog({super.key});

  @override
  ConsumerState<UserListDialog> createState() => _UserListDialogState();
}

class _UserListDialogState extends ConsumerState<UserListDialog> {
  final searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _startChat(User selectedUser) async {
    final authState = ref.read(authStateProvider);
    final currentUser = authState.valueOrNull;

    if (currentUser == null) return;

    final chatListService = ChatListService();

    final chatId = await chatListService.getOrCreateChat(
      currentUser.id,
      selectedUser.id,
      currentUser.name,
      selectedUser.name,
    );

    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ChatScreen(chatId: chatId, chatName: selectedUser.name),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.valueOrNull?.id ?? '';
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select a User',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).hintColor),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: currentUserId.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ref.watch(allUsersProvider(currentUserId)).when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (users) {
                          final filteredUsers = searchQuery.isEmpty
                              ? users
                              : users.where((user) {
                                  final query = searchQuery.toLowerCase();
                                  return user.name.toLowerCase().contains(query) ||
                                      user.email.toLowerCase().contains(query);
                                }).toList();
                          if (filteredUsers.isEmpty) {
                            return Center(
                              child: Text(
                                searchQuery.isEmpty
                                    ? 'No users found'
                                    : 'No users match your search',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).brightness == Brightness.dark ? const DarkColors().avatarBackground : const LightColors().avatarBackground,
                                  child: Text(
                                    (user.name.isNotEmpty ? user.name[0] : '?').toUpperCase(),
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark ? const DarkColors().avatarBorder : const LightColors().avatarBorder,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(user.name, style: Theme.of(context).textTheme.titleMedium),
                                subtitle: Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).iconTheme.color),
                                onTap: () => _startChat(user),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
