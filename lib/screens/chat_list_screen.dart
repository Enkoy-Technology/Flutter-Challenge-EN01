import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_list_provider.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart' as auth_providers;
import '../widgets/user_list_dialog.dart';
import '../utils/time_utils.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import '../theme/app_colors.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatListProvider);
    final authState = ref.watch(authStateProvider);
    final currentUser = authState.valueOrNull;

    return Scaffold(
      drawer: _buildDrawer(context, ref, currentUser),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGradientStart,
                AppColors.primaryGradientEnd,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            backgroundColor: AppColors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: const Text(
              'Message',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
           
          ),
        ),
      ),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (chats) {
          final currentUser = authState.valueOrNull;
          final usersAsync = ref.watch(allUsersProvider(currentUser?.id ?? ''));
          return usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (allUsers) {
              final filtered = _searchQuery.isEmpty
                  ? chats
                  : chats.where((c) {
                      final currentUserId = currentUser?.id;
                      final chatPartnerId = c.id.split('-').first == currentUserId ? c.id.split('-').last : c.id.split('-').first;
                      final user = allUsers.firstWhere(
                        (u) => u.id == chatPartnerId,
                        orElse: () => User(id: chatPartnerId, email: '', name: c.name),
                      );
                      return user.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();
              if (chats.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(color: AppColors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search chats',
                        fillColor: Theme.of(context).colorScheme.surface,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final chat = filtered[index];
                        final currentUserId = currentUser?.id;
                        final chatPartnerId = chat.id.split('-').first == currentUserId ? chat.id.split('-').last : chat.id.split('-').first;
                        final user = allUsers.firstWhere(
                          (u) => u.id == chatPartnerId,
                          orElse: () => User(id: chatPartnerId, email: '', name: chat.name),
                        );
                        final timeStr = TimeUtils.formatChatListTime(chat.lastMessageTime);
                        return ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryGradientStart,
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(chatPartnerId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || snapshot.data == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final data = snapshot.data!.data();
                                  final isOnline = data?['isOnline'] == true;
                                  return Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: isOnline ? AppColors.green : AppColors.grey,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.white, width: 2),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                              ),
                              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(chatPartnerId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData || snapshot.data == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final data = snapshot.data!.data();
                                  final isOnline = data?['isOnline'] == true;
                                  final lastSeen = (data?['lastSeen'] as Timestamp?)?.toDate();
                                  
                                  if (isOnline) {
                                    return const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: Text(
                                        'Online',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  } else if (lastSeen != null) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        TimeUtils.timeAgo(lastSeen),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.greyTextDark,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                          subtitle: Text(
                            user.email.isNotEmpty ? user.email : chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.greyTextDark),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(timeStr, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              if (chat.unreadCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${chat.unreadCount}',
                                    style: const TextStyle(color: AppColors.white, fontSize: 10),
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(chatId: chat.chatId, chatName: user.name),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const UserListDialog(),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, User? currentUser) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dynamic colors = isDark ? AppColors.dark : AppColors.light;
    final Color background = Theme.of(context).colorScheme.surface;
    final Color surface = Theme.of(context).colorScheme.surface;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return Drawer(
      child: Container(
        color: background,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: surface,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: colors.avatarBackground,
                      child: Text(
                        currentUser?.name.isNotEmpty == true
                            ? currentUser!.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colors.avatarBorder,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentUser?.name ?? 'User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Container(
                  color: background,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 8),
                      _buildMenuTile(
                        context: context,
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () {
                          Navigator.pop(context);
                          if (currentUser != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProfileScreen(
                                  userId: currentUser.id,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      _buildMenuTile(
                        context: context,
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed('/settings');
                        },
                      ),
                     
                      _buildMenuTile(
                        context: context,
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('About'),
                              content: const Text('Chat App v1.0.0\nReal-time messaging application'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Divider(),
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'DANGER ZONE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.greyTextDark,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      
                      _buildMenuTile(
                        context: context,
                        icon: Icons.logout,
                        title: 'Logout',
                        iconColor: Colors.orange,
                        textColor: Colors.orange,
                        onTap: () => _handleLogout(context, ref),
                      ),
                      _buildMenuTile(
                        context: context,
                        icon: Icons.delete_forever,
                        title: 'Delete Account',
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () => _handleDeleteAccount(context, ref, currentUser),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final Color onBackground = Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? onBackground,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? onBackground,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: onBackground.withOpacity(0.38),
      ),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange), 
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        final authService = ref.read(auth_providers.authServiceProvider);
        final userService = UserService();
        final currentUser = ref.read(authStateProvider).valueOrNull;
        
        if (currentUser != null) {
          await userService.setUserOffline(currentUser.id);
        }
        
        await authService.signOut();
        
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleDeleteAccount(
    BuildContext context,
    WidgetRef ref,
    User? currentUser,
  ) async {
    if (currentUser == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. All your data will be permanently deleted:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text('• Your profile'),
            Text('• All your messages'),
            Text('• All your chats'),
            SizedBox(height: 12),
            Text(
              'Are you absolutely sure?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final authService = ref.read(auth_providers.authServiceProvider);
        final userService = UserService();
        final userId = currentUser.id;

        bool firestoreDeleted = false;
        bool authDeleted = false;
        String? firestoreError;
        String? authError;

        try {
          await userService.deleteUserData(userId);
          firestoreDeleted = true;
        } catch (e) {
          firestoreError = e.toString();
        }

        try {
          await authService.deleteAccount();
          authDeleted = true;
        } catch (e) {
          authError = e.toString();
        }

        if (firestoreDeleted && authDeleted) {
          if (context.mounted) {
            Navigator.of(context).pop(); 
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account deleted successfully'),
                backgroundColor: AppColors.green,
              ),
            );
          }
        } else if (!firestoreDeleted && !authDeleted) {
          if (context.mounted) {
            Navigator.of(context).pop(); 
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete account:\nFirestore: ${firestoreError ?? "Unknown error"}\nAuth: ${authError ?? "Unknown error"}'),
                backgroundColor: AppColors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } else {
          String errorMessage = '';
          if (firestoreDeleted && !authDeleted) {
            errorMessage = 'User data deleted from Firestore, but failed to delete from Firebase Auth:\n${authError ?? "Unknown error"}';
          } else if (!firestoreDeleted && authDeleted) {
            errorMessage = 'Account deleted from Firebase Auth, but failed to delete user data from Firestore:\n${firestoreError ?? "Unknown error"}';
          }

          if (context.mounted) {
            Navigator.of(context).pop(); 
            
            if (authDeleted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unexpected error during account deletion: $e'),
              backgroundColor: AppColors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }
}

