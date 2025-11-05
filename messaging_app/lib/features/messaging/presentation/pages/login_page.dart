import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/messaging_provider.dart';
import 'chat_list_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _nameController = TextEditingController();
  final _predefinedUsers = [
    {'id': 'user1', 'name': 'Alice', 'color': Colors.purple},
    {'id': 'user2', 'name': 'Bob', 'color': Colors.teal},
    {'id': 'user3', 'name': 'Charlie', 'color': Colors.orange},
    {'id': 'user4', 'name': 'Diana', 'color': Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF9C88FF),
              Color(0xFFB8A9FF),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome to ChatApp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your identity to start chatting',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Quick Login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._predefinedUsers.map((user) => Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton(
                          onPressed: () => _loginAsUser(user['id']! as String, user['name']! as String),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.grey[50],
                            foregroundColor: const Color(0xFF2D3748),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: user['color']! as Color,
                                child: Text(
                                  (user['name']! as String)[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Login as ${user['name']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Custom Name',
                          hintText: 'Enter your name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                          ),
                          prefixIcon: const Icon(Icons.person, color: Color(0xFF6C63FF)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loginWithCustomName,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Login with Custom Name',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loginAsUser(String userId, String userName) {
    ref.read(currentUserIdProvider.notifier).state = userId;
    ref.read(currentUserNameProvider.notifier).state = userName;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChatListPage()),
    );
  }

  void _loginWithCustomName() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      ref.read(currentUserIdProvider.notifier).state = userId;
      ref.read(currentUserNameProvider.notifier).state = name;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatListPage()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}