import '../../data/repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<UserEntity?> call({
    required String email,
    required String password,
  }) async {
    return await repository.signIn(
      email: email,
      password: password,
    );
  }
}


