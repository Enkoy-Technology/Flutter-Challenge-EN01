import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/services/storage_service.dart';

class AuthController extends GetxController {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final LogoutUsecase logoutUsecase;
  final ChatRepository chatRepository;

  final currentUser = Rx<UserEntity?>(null);
  final isLoading = false.obs;
  final error = Rx<String?>(null);
  final isLoggedIn = false.obs;

  AuthController({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.logoutUsecase,
    required this.chatRepository,
  });

  @override
  void onInit() {
    super.onInit();
    
    Future.microtask(() => _checkAuthStatus());
  }

  
  Future<void> _checkAuthStatus() async {
    try {
      final storageService = Get.find<StorageService>();
      final userId = storageService.getUserId();

      if (userId != null && userId.isNotEmpty) {
        isLoggedIn.value = true;
        Future.delayed(
          const Duration(milliseconds: 500),
          () => Get.offAllNamed(AppRoutes.CHAT_LIST),
        );
      } else {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      print('Error checking auth status: $e');
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = null;

      final user = await loginUsecase(email, password);
      currentUser.value = user;

      
      final storageService = Get.find<StorageService>();
      await storageService.saveUserId(user.id);
      await storageService.saveUserEmail(user.email);

      isLoggedIn.value = true;
      
      
      Future.delayed(
        const Duration(milliseconds: 300),
        () => Get.offAllNamed(AppRoutes.CHAT_LIST),
      );
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<void> register(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      isLoading.value = true;
      error.value = null;

      final user = await registerUsecase(email, password, displayName);
      currentUser.value = user;

      
      final storageService = Get.find<StorageService>();
      await storageService.saveUserId(user.id);
      await storageService.saveUserEmail(user.email);

      isLoggedIn.value = true;
      
      
      Future.delayed(
        const Duration(milliseconds: 300),
        () => Get.offAllNamed(AppRoutes.CHAT_LIST),
      );
    } catch (e) {
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await logoutUsecase();

      currentUser.value = null;
      isLoggedIn.value = false;

      final storageService = Get.find<StorageService>();
      await storageService.clearAll();

      Future.delayed(
        const Duration(milliseconds: 300),
        () => Get.offAllNamed(AppRoutes.LOGIN),
      );
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
