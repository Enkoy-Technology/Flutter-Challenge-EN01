import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'features/auth/presentation/login/login_page.dart';
import 'features/auth/auth_controller.dart';
import 'features/home/presentation/home_page.dart';
import 'core/utils/app_lifecycle_manager.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Chat App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: AppLifecycleManager(
        child: authState.when(
          data: (user) =>
              user != null ? const HomePage() : const LoginPage(),
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(child: Text('Error: $error')),
          ),
        ),
      ),
    );
  }
}

