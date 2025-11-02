import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserModel> call(String email, String password) {
    return repository.login(email, password);
  }
}
