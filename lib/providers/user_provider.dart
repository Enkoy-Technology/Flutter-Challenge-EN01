import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

final userServiceProvider = Provider<UserService>((ref) => UserService());

final allUsersProvider =
    StreamProvider.family<List<User>, String>((ref, currentUserId) {
  final userService = ref.watch(userServiceProvider);
  return userService.getAllUsers(currentUserId);
});
