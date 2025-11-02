import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/models/app_user.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final Rx<AppUser?> currentUser = Rx<AppUser?>(null);
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  @override
  void onReady() {
    super.onReady();
    _authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        currentUser.value = await _authRepository.getCurrentUser();
        Get.offAllNamed('/chat_list');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }

  void clearError() {
    if (errorMessage.value != null) {
      errorMessage.value = null;
    }
  }

  void signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;
    clearError();
    try {
      await _authRepository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage.value = 'This email is already registered.';
          break;
        case 'weak-password':
          errorMessage.value = 'The password is too weak.';
          break;
        default:
          errorMessage.value = 'Something went wrong. Please try again.';
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void login({required String email, required String password}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    clearError();
    try {
      await _authRepository.login(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        errorMessage.value = 'Incorrect email or password.';
      } else {
        errorMessage.value = 'Something went wrong. Please try again.';
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void signOut() {
    _authRepository.signOut();
  }
}
