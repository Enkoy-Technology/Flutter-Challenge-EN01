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
}
