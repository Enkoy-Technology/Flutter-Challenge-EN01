import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:logging/logging.dart';

import 'core/config/app_router.dart';
import 'core/config/theme.dart';
import 'core/di/injector.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<LoginCubit>(create: (_) => sl<LoginCubit>()),
        BlocProvider<RegisterCubit>(create: (_) => sl<RegisterCubit>()),
        BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()),
      ],
      child: MaterialApp(
        title: 'Flutter Chat App',
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: AppRouter.splash,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
