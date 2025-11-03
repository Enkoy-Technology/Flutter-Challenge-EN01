import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/utils/message_formatter.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/chat_list/chat_list_bloc.dart';
import '../../bloc/chat_list/chat_list_event.dart';
import '../../bloc/chat_list/chat_list_state.dart';
import '../../widgets/chat_list_shimmer.dart';
import '../chat_room/chat_room_page.dart';
import 'new_chat_page.dart';
import '../profile/profile_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ChatListBloc>().add(ChatListSubscriptionRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  leading: _isSearching
      ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          },
        )
      : Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
  title: _isSearching
      ? Container(
          width: 280,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), // ← subtle tint
            borderRadius: BorderRadius.circular(20), // ← perfect pill shape
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Search chats...',
              hintStyle: const TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8, // ← centers text vertically
              ),
              isDense: true,
              // 👇 THIS IS THE KEY — REMOVE ANY BACKGROUND FROM TEXTFIELD ITSELF
              fillColor: Colors.transparent, // ← critical
              filled: true, // ← required for fillColor to work
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        )
      : const Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
  actions: [
    IconButton(
      icon: Icon(_isSearching ? Icons.close : Icons.search),
      onPressed: () {
        setState(() {
          _isSearching = !_isSearching;
          if (!_isSearching) {
            _searchQuery = '';
            _searchController.clear();
          }
        });
      },
    ),
  ],
),
      drawer: SizedBox(
        width: 250,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                height: 180,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(Icons.chat_bubble, size: 48, color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'Chat App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ProfilePage(showBackButton: true),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Help & Support coming soon!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'Chat App',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.chat_bubble, size: 48),
                    children: const [
                      Text(
                        'A modern real-time messaging application built with Flutter and Supabase.',
                      ),
                    ],
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthBloc>().add(AuthSignOutRequested());
                },
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          if (state is ChatListLoading) {
            return const ChatListShimmer();
          }

          if (state is ChatListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading chats',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatListBloc>().add(ChatListLoadRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ChatListEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a new conversation',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          if (state is ChatListLoaded) {
            // Filter chats based on search query
            final filteredChats = _searchQuery.isEmpty
                ? state.chats
                : state.chats.where((chat) {
                    final displayName =
                        chat.otherUser?.displayName.toLowerCase() ?? '';
                    return displayName.contains(_searchQuery);
                  }).toList();

            if (filteredChats.isEmpty && _searchQuery.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No chats found',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try a different search term',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatListBloc>().add(ChatListLoadRequested());
              },
              child: ListView.separated(
                itemCount: filteredChats.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final chat = filteredChats[index];
                  final otherUser = chat.otherUser;
                  final lastMessage = chat.lastMessage;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: otherUser?.avatarUrl != null
                          ? NetworkImage(otherUser!.avatarUrl!)
                          : null,
                      child: otherUser?.avatarUrl == null
                          ? Text(
                              otherUser?.displayName
                                      .substring(0, 1)
                                      .toUpperCase() ??
                                  '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherUser?.displayName ?? 'Unknown User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (lastMessage != null)
                          Text(
                            DateFormatter.formatChatListTime(
                              lastMessage.createdAt,
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage != null
                                ? MessageFormatter.formatMessagePreview(
                                    lastMessage.content,
                                    lastMessage.messageType,
                                  )
                                : 'No messages yet',
                            style: TextStyle(
                              color: chat.unreadCount > 0
                                  ? Colors.black87
                                  : Colors.grey[600],
                              fontWeight: chat.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              chat.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatRoomPage(
                            chatId: chat.id,
                            otherUser: otherUser!,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewChatPage()));
  },
  backgroundColor: const Color(0xFF6C5CE7),
  foregroundColor: Colors.white,
  elevation: 4,
  shape: CircleBorder(), 
  child: const Icon(Icons.add, size: 28), 
),
    );
  }
}
