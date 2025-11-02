import 'package:firebase_auth/firebase_auth.dart';

class AppConstants {
  static const appName = 'Flutter Chat Challenge';
  static const usersCollection = 'users';
  static const messagesCollection = 'messages';
  static final contacts = [
    {'name': 'John Doe', 'status': 'Hey there! I am using ChatApp'},
    {'name': 'Alice', 'status': 'Busy'},
    {'name': 'Michael', 'status': 'At work'},
    {'name': 'Sarah', 'status': 'Available'},
  ];

  static final stories = [
    {'name': 'You', 'isSeen': false},
    {'name': 'Sarah', 'isSeen': true},
    {'name': 'Mike', 'isSeen': false},
    {'name': 'Olivia', 'isSeen': true},
  ];
  static final calls = [
    {'name': 'John Doe', 'time': 'Yesterday, 9:30 PM'},
    {'name': 'Alice', 'time': 'Today, 11:45 AM'},
    {'name': 'Michael', 'time': 'Monday, 5:10 PM'},
  ];

  static String get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
}
