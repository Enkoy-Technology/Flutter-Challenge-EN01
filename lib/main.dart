import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:logging/logging.dart';

import 'package:provider/provider.dart';
import 'core/config/app_router.dart';
import 'core/di/injector.dart';
import 'core/services/theme_service.dart';
import 'core/services/preferences_service.dart';
import 'core/services/presence_service.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/cubit/login_cubit.dart';
import 'features/auth/presentation/bloc/cubit/register_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupInjector();
  Logger.root.level = Level.ALL; // Set the minimum logging level
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
      print('Stack Trace: ${record.stackTrace}');
    }
  });
  final presenceService = PresenceService();

  // Set up presence tracking when user logs in
  FirebaseAuth.instance.authStateChanges().listen((user) async {
    if (user != null) {
      await presenceService.setupPresence(user.uid);
    } else {
      await presenceService.cleanup();
    }
  });

  runApp(MyApp(presenceService: presenceService));
}

class MyApp extends StatefulWidget {
  final PresenceService presenceService;

  const MyApp({super.key, required this.presenceService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - set online
        widget.presenceService.setupPresence(user.uid);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App went to background or was killed - set offline
        widget.presenceService.setOffline();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => PreferencesService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
          BlocProvider<LoginCubit>(create: (_) => sl<LoginCubit>()),
          BlocProvider<RegisterCubit>(create: (_) => sl<RegisterCubit>()),
          BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
        ],
        child: Consumer<ThemeService>(
          builder: (context, themeService, child) {
            // Use the theme service theme if initialized, otherwise use light theme
            final currentTheme = themeService.isInitialized
                ? themeService.theme
                : ThemeData.light();

            return MaterialApp(
              title: 'Flutter Chat App',
              theme: currentTheme,
              onGenerateRoute: AppRouter.onGenerateRoute,
              initialRoute: AppRouter.splash,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
