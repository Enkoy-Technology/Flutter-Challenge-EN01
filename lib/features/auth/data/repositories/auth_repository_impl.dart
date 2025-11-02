import '../models/user_model.dart';
import '../datasources/auth_remote_source.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource remoteSource;

  AuthRepositoryImpl({required this.remoteSource});

  @override
  Future<UserModel> login(String email, String password) {
    return remoteSource.login(email, password);
  }

  @override
  Future<UserModel> register(String email, String password, String name) {
    return remoteSource.register(email, password, name);
  }

  @override
  Stream<UserModel?> get userStream => remoteSource.authStateChanges.map(
    (user) => user != null
        ? UserModel(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
          )
        : null,
  );

  @override
  Future<void> logout() => remoteSource.logout();
}
