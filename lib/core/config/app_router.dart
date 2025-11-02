import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/chat/presentation/pages/chat_list_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/chat/presentation/pages/home_screen.dart';

class AppRouter {
  static const login = '/login';
  static const register = '/register';
  static const chats = '/chats';
  static const chatScreen = '/chat-screen';
  static const splash = '/splash';
  static const home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case chats:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case chatScreen:
        final arguments = settings.arguments as Map<String, dynamic>?;
        if (arguments == null) {
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: arguments['chatId'] as String,
            receiverName: arguments['receiverName'] as String,
            receiverId: arguments['receiverId'] as String,
          ),
        );
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
