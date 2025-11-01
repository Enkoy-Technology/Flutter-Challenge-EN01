import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/skeleton_widgets.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/chat_utils.dart';
import '../../chat/presentation/chat_room/chat_room_page.dart';
import '../../chat/chat_controller.dart';
import '../../auth/data/models/user_model.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startChat(String otherUserId, String otherUserName,
      String? otherUserPhotoUrl) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final repository = ref.read(chatRepositoryProvider);
      final chatId = await repository.createOrGetChat(currentUserId, otherUserId);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(
              chatId: chatId,
              otherUserId: otherUserId,
              otherUserName: otherUserName,
              otherUserPhotoUrl: otherUserPhotoUrl,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search users by name...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AppConstants.usersCollection)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const UsersListSkeleton();
                }

                if (snapshot.hasError) {
                  return ErrorDisplayWidget(
                    message: 'Error loading users: ${snapshot.error}',
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter users: exclude current user and apply search filter
                var users = snapshot.data!.docs
                    .map((doc) => UserModel.fromFirestore(doc))
                    .where((user) => user.id != currentUserId)
                    .toList();

                // Apply case-insensitive search filter if query is not empty
                if (_searchQuery.isNotEmpty) {
                  final queryLower = _searchQuery.toLowerCase();
                  users = users.where((user) {
                    // Case-insensitive search in name
                    return user.name.toLowerCase().contains(queryLower) ||
                        // Also search in email if needed
                        (user.email.toLowerCase().contains(queryLower));
                  }).toList();
                }

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No other users available'
                              : 'No users match your search',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: user.photoUrl != null
                            ? CachedNetworkImageProvider(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 18),
                              )
                            : null,
                      ),
                      title: Text(user.name),
                      subtitle: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: user.isOnline 
                                  ? colorScheme.tertiary 
                                  : colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        onPressed: () => _startChat(
                          user.id,
                          user.name,
                          user.photoUrl,
                        ),
                      ),
                      onTap: () => _startChat(
                        user.id,
                        user.name,
                        user.photoUrl,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

