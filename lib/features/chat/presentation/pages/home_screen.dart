import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/auth/presentation/pages/profile_screen.dart';
import 'package:flutter_chat_app/features/chat/presentation/pages/call_screen.dart';
import 'package:flutter_chat_app/features/chat/presentation/pages/contact_screen.dart';
import 'package:flutter_chat_app/features/chat/presentation/pages/story_screen.dart';
import 'chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ChatListScreen(),
    CallScreen(),
    StoryScreen(),
    ContactsScreen(),
    ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: colorScheme.primary,
              onPressed: () {
                // TODO: Add new chat
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: theme.brightness == Brightness.dark
            ? Colors.grey.shade400
            : Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "Call"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Story"),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: "Contacts",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
