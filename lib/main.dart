import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'presentation/controllers/auth_controller.dart';
import 'presentation/views/chat_list_screen.dart';
import 'presentation/views/chat_screen.dart';
import 'presentation/views/signup_screen.dart';
import 'firebase_options.dart'; // Make sure this file exists

void main() async {
  // 1. MUST BE FIRST: Ensure Flutter bindings are ready
  WidgetsFlutterBinding.ensureInitialized();

  // 2. MUST BE SECOND: Initialize the core Firebase App
  // This creates the [DEFAULT] app instance required by other services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. NOW it is safe to activate App Check
  // Use the debug provider in debug mode, and Play Integrity in release.
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
  );

  // Initialize your Auth Controller and run the app
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AdvancedChatChallenge',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const ChatListScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/chat_list', page: () => const ChatListScreen()),
        GetPage(name: '/chat', page: () => ChatScreen()),
      ],
    );
  }
}
