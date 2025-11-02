import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

import '../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/domain/usecases/get_messages_usecase.dart';
import '../../features/chat/domain/usecases/upload_media_usecase.dart';
import '../../features/chat/domain/usecases/mark_as_read_usecase.dart';
import '../../features/chat/presentation/controllers/chat_controller.dart';
import '../../features/chat/presentation/controllers/chat_list_controller.dart';

import '../../core/services/storage_service.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {

    
    
    
    Get.put<FirebaseAuth>(FirebaseAuth.instance);
    Get.put<FirebaseFirestore>(FirebaseFirestore.instance);

    Get.lazyPut<StorageService>(() => StorageService());

    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: Get.find<FirebaseAuth>(),
        firestore: Get.find<FirebaseFirestore>(),
      ),
    );

    Get.lazyPut<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(
        firestore: Get.find<FirebaseFirestore>(),
      ),
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
      ),
    );

    Get.lazyPut<ChatRepository>(
      () => ChatRepositoryImpl(
        remoteDataSource: Get.find<ChatRemoteDataSource>(),
      ),
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

    
    Get.lazyPut<SendMessageUsecase>(
      () => SendMessageUsecase(Get.find<ChatRepository>()),
    );
    Get.lazyPut<GetMessagesUsecase>(
      () => GetMessagesUsecase(Get.find<ChatRepository>()),
    );
    Get.lazyPut<UploadMediaUsecase>(
      () => UploadMediaUsecase(Get.find<ChatRepository>()),
    );
    Get.lazyPut<MarkAsReadUsecase>(
      () => MarkAsReadUsecase(Get.find<ChatRepository>()),
    );

    
    
    
   Get.put<AuthController>(
  AuthController(
    loginUsecase: Get.find<LoginUsecase>(),
    registerUsecase: Get.find<RegisterUsecase>(),
    logoutUsecase: Get.find<LogoutUsecase>(),
    chatRepository: Get.find<ChatRepository>(),
  ),
);


Get.put<ChatController>(
  ChatController(
    sendMessageUsecase: Get.find<SendMessageUsecase>(),
    getMessagesUsecase: Get.find<GetMessagesUsecase>(),
    uploadMediaUsecase: Get.find<UploadMediaUsecase>(),
    markAsReadUsecase: Get.find<MarkAsReadUsecase>(),
    authDataSource: Get.find<AuthRemoteDataSource>(),
  ),
);

    Get.lazyPut<ChatListController>(
      () => ChatListController(
        chatRepository: Get.find<ChatRepository>(),
      ),
    );

  }
}
