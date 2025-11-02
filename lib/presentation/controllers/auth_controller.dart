
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/models/app_user.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);

  @override
  void onReady() {
    super.onReady();
    _authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        currentUser.value = await _authRepository.getCurrentUser();
        Get.offAllNamed('/chat_list');
      } else {
        Get.offAllNamed('/signup');
      }
    });
  }

  void signUp({
    required String email,
    required String password,
    required String fullName,
    required XFile profileImage,
  }) {
    _authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      profileImage: profileImage,
    );
  }

  void signOut() {
    _authRepository.signOut();
  }
}
