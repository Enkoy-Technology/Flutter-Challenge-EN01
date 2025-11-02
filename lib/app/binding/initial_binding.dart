import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    
    Get.lazyPut<StorageService>(() => StorageService());
  }
}
