import 'package:flutter/material.dart';
import 'package:flutter_chat_app/features/chat/presentation/pages/call_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final contacts = [
      {'name': 'John Doe', 'status': 'Hey there! I am using ChatApp'},
      {'name': 'Alice', 'status': 'Busy'},
      {'name': 'Michael', 'status': 'At work'},
      {'name': 'Sarah', 'status': 'Available'},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ModernHeader(
              title: "Contacts",
              subtitle: "Your connections",
              icon: Icons.contacts_outlined,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.person, color: colorScheme.primary),
                    ),
                    title: Text(
                      contact['name']!,
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      contact['status']!,
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chat_bubble_outline,
                      color: colorScheme.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
