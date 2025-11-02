import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<UserEntity> call(
    String email,
    String password,
    String displayName,
  ) {
    return repository.register(email, password, displayName);
  }
}
