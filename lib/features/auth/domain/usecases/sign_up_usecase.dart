import '../../data/repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity?> call({
    required String email,
    required String password,
    required String name,
  }) async {
    return await repository.signUp(
      email: email,
      password: password,
      name: name,
    );
  }
}


