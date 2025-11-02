import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/chat_remote_datasource.dart';
import '../data/repositories/chat_repository_impl.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/usecases/send_message_usecase.dart';
import '../domain/usecases/get_messages_usecase.dart';
import '../domain/usecases/upload_media_usecase.dart';
import '../domain/usecases/mark_as_read_usecase.dart';
import '../presentation/controllers/chat_controller.dart';
import '../presentation/controllers/chat_list_controller.dart';
import '../../auth/data/datasources/auth_remote_datasource.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    

    
    Get.lazyPut<FirebaseFirestore>(() => FirebaseFirestore.instance);
    Get.lazyPut<FirebaseAuth>(() => FirebaseAuth.instance);

    
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

    
    Get.lazyPut<ChatRepository>(
      () => ChatRepositoryImpl(
        remoteDataSource: Get.find<ChatRemoteDataSource>(),
      ),
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

    
    Get.lazyPut<ChatController>(
      () => ChatController(
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
