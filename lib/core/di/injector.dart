import 'package:flutter_chat_app/features/auth/data/datasources/auth_remote_source.dart';
import 'package:flutter_chat_app/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_chat_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_chat_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_chat_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_chat_app/features/auth/presentation/bloc/cubit/login_cubit.dart';
import 'package:flutter_chat_app/features/auth/presentation/bloc/cubit/register_cubit.dart';
import 'package:flutter_chat_app/features/chat/data/datasources/chat_remote_source.dart';
import 'package:flutter_chat_app/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter_chat_app/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:flutter_chat_app/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_chat_app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:flutter_chat_app/features/chat/presentation/bloc/cubit/chat_list_cubit.dart';
import 'package:get_it/get_it.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../services/firebase_storage_service.dart';

final sl = GetIt.instance;

Future<void> setupInjector() async {
  // Core services
  sl.registerLazySingleton(() => FirebaseAuthService());
  sl.registerLazySingleton(() => FirestoreService());
  sl.registerLazySingleton(() => FirebaseStorageService());

  // Remote Source
  sl.registerLazySingleton(() => AuthRemoteSource());

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // Cubits & Blocs
  sl.registerFactory(() => LoginCubit(sl()));
  sl.registerFactory(
    () => RegisterCubit(registerUseCase: sl(), loginUseCase: sl()),
  );

  sl.registerLazySingleton(() => AuthBloc(sl()));

  // Remote Sources
  sl.registerLazySingleton(() => ChatRemoteSource());

  // Repositories
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => ChatBloc(getMessagesUseCase: sl(), sendMessageUseCase: sl()),
  );

  // Cubit
  sl.registerFactory(() => ChatListCubit(repository: sl()));
}
