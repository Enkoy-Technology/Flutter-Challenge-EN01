import 'package:go_router/go_router.dart';
import '../../../features/auth/presentation/screens/login_screen.dart';
import '../../../features/auth/presentation/screens/register_screen.dart';
import '../../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../../features/chat/presentation/screens/chat_screen.dart';
import '../../../features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/chats', builder: (_, __) => const ChatListScreen()),
      GoRoute(
        path: '/chat/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return ChatScreen(chatId: id);
        },
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
}
