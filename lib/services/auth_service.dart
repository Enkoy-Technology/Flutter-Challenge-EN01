import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  Stream<firebase_auth.User?> get authStateChanges {
    try {
      return _auth.authStateChanges().handleError((error, stackTrace) {
        return null;
      }, test: (error) => true);
    } catch (e) {
      return Stream.value(null);
    }
  }

  User? get currentUser {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ??
            firebaseUser.email?.split('@')[0] ??
            'User',
      );
    } catch (e) {
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        try {
          final userService = UserService();
          await userService.createUserProfile(
            firebaseUser.uid,
            firebaseUser.email ?? email,
            firebaseUser.displayName ??
                firebaseUser.email?.split('@')[0] ??
                'User',
            '',
          );
          try {
            final token = await FirebaseMessaging.instance.getToken();
            if (token != null) {
              await userService.updateUserFcmToken(firebaseUser.uid, token);
            }
          } catch (e) {
            debugPrint('Error updating FCM token: $e');
          }
        } catch (e) {
          debugPrint('Error creating user profile: $e');
        }
      }
      return currentUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      firebase_auth.User? user = credential.user;

      if (user == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        user = _auth.currentUser;
      }

      if (user != null) {
        try {
          await user.updateDisplayName(name);
        } catch (displayNameError) {
          debugPrint('Error updating display name: $displayNameError');
        }

        try {
          final userService = UserService();
          await userService.createUserProfile(user.uid, email, name, password);
          try {
            final token = await FirebaseMessaging.instance.getToken();
            if (token != null) {
              await userService.updateUserFcmToken(user.uid, token);
            }
          } catch (e) {
            debugPrint('Error updating FCM token: $e');
          }
        } catch (e) {
          rethrow;
        }
        return User(
          id: user.uid,
          email: user.email ?? email,
          name: name,
        );
      }

      return null;
    } catch (e) {
      final errorStr = e.toString();

      if (errorStr.contains('PigeonUserDetails') ||
          errorStr.contains('List<Object?>') ||
          errorStr.contains('type cast')) {
        await Future.delayed(const Duration(milliseconds: 500));
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          try {
            await currentUser.updateDisplayName(name);
          } catch (displayNameError) {
            debugPrint('Error updating display name: $displayNameError');
          }

          try {
            final userService = UserService();
            await userService.createUserProfile(
                currentUser.uid, email, name, password);
            try {
              final token = await FirebaseMessaging.instance.getToken();
              if (token != null) {
                await userService.updateUserFcmToken(currentUser.uid, token);
              }
            } catch (e) {
              debugPrint('Error updating FCM token: $e');
            }

            return User(
              id: currentUser.uid,
              email: currentUser.email ?? email,
              name: name,
            );
          } catch (firestoreError) {
            rethrow;
          }
        }
      }

      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
