import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_screen.dart';
import 'services/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'providers/auth_provider.dart';
import 'providers/current_chat_provider.dart';
import 'theme/app_colors.dart';
import 'screens/settings_screen.dart';
import 'providers/theme_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null && payload.startsWith('chat:')) {
      final payloadParts = payload.split(':');
      if (payloadParts.length >= 3) {
        String chatId = payloadParts[1];
        String chatName = Uri.decodeFull(payloadParts[2]);
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(chatId: chatId, chatName: chatName),
          ),
        );
      }
    }
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (prev, next) async {
      final user = next.valueOrNull;
      if (user != null) {
        final userService = UserService();
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await userService.updateUserFcmToken(user.id, token);
        }
        await userService.setUserOnline(user.id);
      } else if (prev?.valueOrNull != null) {
        final userService = UserService();
        await userService.setUserOffline(prev!.valueOrNull!.id);
      }
    });
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final chatId = message.data['chatId'];
      final payload = message.data['payload'];

      final currentChatId = ref.read(currentChatProvider);
      if (chatId != null && currentChatId == chatId) {
        return;
      }

      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification?.title,
          message.notification?.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'chat_channel',
              'Chat Notifications',
              channelDescription: 'Chat message notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: payload ?? message.data['payload'],
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload = message.data['payload'] ?? message.data['chatId'];

      String? chatId;
      String? chatName;

      if (payload != null && payload.startsWith('chat:')) {
        final payloadParts = payload.split(':');
        if (payloadParts.length >= 3) {
          chatId = payloadParts[1];
          chatName = Uri.decodeFull(payloadParts[2]);
        }
      } else {
        chatId = message.data['chatId'];
        chatName = message.data['chatName'];
      }

      if (chatId != null && chatName != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ChatScreen(chatId: chatId!, chatName: chatName!),
          ),
        );
      }
    });
    final appTheme = ref.watch(themeProvider);

    ThemeMode themeMode;
    switch (appTheme) {
      case AppThemeMode.light:
        themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/chats': (context) => const ChatListScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
