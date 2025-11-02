import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/config/app_constants.dart';
import 'package:flutter_chat_app/features/chat/presentation/widgets/modern_header.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ModernHeader(
              title: "Calls",
              subtitle: "Recent call history",
              icon: Icons.call,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: AppConstants.calls.length,
                itemBuilder: (context, index) {
                  final call = AppConstants.calls[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.phone, color: colorScheme.primary),
                    ),
                    title: Text(
                      call['name']!,
                      style: TextStyle(
                        color: colorScheme.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      call['time']!,
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    trailing: Icon(Icons.call, color: colorScheme.primary),
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
