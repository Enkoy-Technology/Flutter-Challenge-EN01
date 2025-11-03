import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/services/cache_service.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/config_validator.dart';
import 'features/chat/data/repositories/auth_repository.dart';
import 'features/chat/data/repositories/chat_repository.dart';
import 'features/chat/presentation/bloc/auth/auth_bloc.dart';
import 'features/chat/presentation/bloc/auth/auth_event.dart';
import 'features/chat/presentation/bloc/auth/auth_state.dart' as app_auth;
import 'features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'features/chat/presentation/pages/auth/login_page.dart';
import 'features/chat/presentation/pages/main_navigation_page.dart';

late CacheService cacheService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Validate configuration
    if (!ConfigValidator.isSupabaseConfigured()) {
      debugPrint(
        '⚠️ Configuration Error: ${ConfigValidator.getConfigurationError()}',
      );
    }

    // Initialize Supabase
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );

    // Initialize cache service
    final prefs = await SharedPreferences.getInstance();
    cacheService = CacheService(prefs);

    debugPrint('✅ Supabase initialized successfully');
    debugPrint('✅ Cache service initialized successfully');
  } catch (e) {
    debugPrint('❌ Failed to initialize: $e');
    debugPrint('URL: ${AppConstants.supabaseUrl}');
    debugPrint('Key length: ${AppConstants.supabaseAnonKey.length}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthBloc(AuthRepository(Supabase.instance.client))
            ..add(AuthCheckRequested()),
      child: MaterialApp(
        title: 'Chat App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<AuthBloc, app_auth.AuthState>(
          builder: (context, state) {
            if (state is app_auth.AuthLoading ||
                state is app_auth.AuthInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is app_auth.AuthAuthenticated) {
              return BlocProvider(
                create: (context) => ChatListBloc(
                  ChatRepository(Supabase.instance.client, cacheService),
                  state.user.id,
                ),
                child: const MainNavigationPage(),
              );
            }

            return const LoginPage();
          },
        ),
      ),
    );
  }
}
