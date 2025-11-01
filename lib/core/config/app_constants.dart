import 'package:firebase_auth/firebase_auth.dart';

class AppConstants {
  static const appName = 'Flutter Chat Challenge';
  static const usersCollection = 'users';
  static const messagesCollection = 'messages';

  static String get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
}
