import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';
import 'presentation/controllers/auth_controller.dart';

class DependencyInjection {
  static Future<void> init() async {
    // 1. MUST BE FIRST: Ensure Flutter bindings are ready
    WidgetsFlutterBinding.ensureInitialized();

    // 2. MUST BE SECOND: Initialize the core Firebase App
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. NOW it is safe to activate App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
    );

    // Initialize your Auth Controller
    Get.put(AuthController());
  }
}
