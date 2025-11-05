import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.map((firebaseUser) {
    if (firebaseUser == null) return null;
    try {
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
  }).handleError((error, stackTrace) {
    return null;
  }, test: (error) => true);
});
