import 'package:get/get.dart';
import '../presentation/views/chat_list_screen.dart';
import '../presentation/views/chat_screen.dart';
import '../presentation/views/login_screen.dart';
import '../presentation/views/new_chat_screen.dart';
import '../presentation/views/profile_screen.dart';
import '../presentation/views/signup_screen.dart';

class AppRoutes {
  static final List<GetPage> routes = [
    GetPage(name: '/', page: () => const ChatListScreen()),
    GetPage(name: '/login', page: () => LoginScreen()),
    GetPage(name: '/profile', page: () => const ProfileScreen()),
    GetPage(name: '/signup', page: () => SignupScreen()),
    GetPage(name: '/chat_list', page: () => const ChatListScreen()),
    GetPage(name: '/new_chat', page: () => const NewChatScreen()),
    GetPage(name: '/chat', page: () => ChatScreen()),
  ];
}
