import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 18),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('App Theme'),
            subtitle: Text(
              themeMode == AppThemeMode.system
                  ? 'System Default'
                  : themeMode == AppThemeMode.light
                      ? 'Light'
                      : 'Dark',
            ),
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.system,
            groupValue: themeMode,
            title: const Text('System Default'),
            onChanged: (value) {
              if (value != null) ref.read(themeProvider.notifier).setTheme(value);
            },
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.light,
            groupValue: themeMode,
            title: const Text('Light'),
            onChanged: (value) {
              if (value != null) ref.read(themeProvider.notifier).setTheme(value);
            },
          ),
          RadioListTile<AppThemeMode>(
            value: AppThemeMode.dark,
            groupValue: themeMode,
            title: const Text('Dark'),
            onChanged: (value) {
              if (value != null) ref.read(themeProvider.notifier).setTheme(value);
            },
          ),
        ],
      ),
    );
  }
}
