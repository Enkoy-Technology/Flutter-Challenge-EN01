import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> register(String email, String password, String name);
  Future<UserModel> login(String email, String password);
  Stream<UserModel?> get userStream;
  Future<void> logout();
}
