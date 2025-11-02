import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../presentation/controllers/auth_controller.dart';
import '../../chat/domain/repositories/chat_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    

    
    Get.lazyPut<FirebaseAuth>(() => FirebaseAuth.instance);
    Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance);

    
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: Get.find<FirebaseAuth>(),
        firestore: Get.find<FirebaseFirestore>(),
      ),
    );

    
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: Get.find<AuthRemoteDataSource>()),
    );

    
    Get.lazyPut<LoginUsecase>(
      () => LoginUsecase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<RegisterUsecase>(
      () => RegisterUsecase(Get.find<AuthRepository>()),
    );

    Get.lazyPut<LogoutUsecase>(
      () => LogoutUsecase(Get.find<AuthRepository>()),
    );

    
    Get.lazyPut<AuthController>(
      () => AuthController(
        loginUsecase: Get.find<LoginUsecase>(),
        registerUsecase: Get.find<RegisterUsecase>(),
        logoutUsecase: Get.find<LogoutUsecase>(),
        chatRepository: Get.find<ChatRepository>(),
      ),
    );
  }
}
