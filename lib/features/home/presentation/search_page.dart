import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/constants/app_constants.dart';
import '../../chat/presentation/chat_room/chat_room_page.dart';
import '../../chat/chat_controller.dart';
import '../../auth/data/models/user_model.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
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
        title: const Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
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
            child: _searchQuery.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for users to start a chat',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(AppConstants.usersCollection)
                        .where('name', isGreaterThanOrEqualTo: _searchQuery)
                        .where('name',
                            isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingWidget();
                      }

                      if (snapshot.hasError) {
                        return ErrorDisplayWidget(
                          message: 'Error searching users: ${snapshot.error}',
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No users found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        );
                      }

                      final users = snapshot.data!.docs
                          .map((doc) => UserModel.fromFirestore(doc))
                          .where((user) => user.id != currentUserId)
                          .toList();

                      if (users.isEmpty) {
                        return Center(
                          child: Text(
                            'No users found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
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
                            trailing: const Icon(Icons.chat_bubble_outline),
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

