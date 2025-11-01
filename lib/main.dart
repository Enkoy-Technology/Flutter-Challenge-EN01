import 'package:enkoy_chat/app/app.notification.dart';
import 'package:enkoy_chat/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:enkoy_chat/app/app.bottomsheets.dart';
import 'package:enkoy_chat/app/app.dialogs.dart';
import 'package:enkoy_chat/app/app.locator.dart';
import 'package:enkoy_chat/app/app.router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked_services/stacked_services.dart';

SharedPreferences? localStorage;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  await setupLocator();
  localStorage = await SharedPreferences.getInstance();
  initMessaging();
  setupDialogUi();
  setupBottomSheetUi();
  runApp(
    const MainApp(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.startupView,
      theme: FlexThemeData.light(
        useMaterial3: true,
        scheme: FlexScheme.purpleM3,
        // colorScheme: AppThemeScheme.lightColorScheme(),
        fontFamily: GoogleFonts.roboto().fontFamily,
        typography: Typography.material2021(platform: defaultTargetPlatform),
      ),
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [
        StackedService.routeObserver,
      ],
    );
  }
}
