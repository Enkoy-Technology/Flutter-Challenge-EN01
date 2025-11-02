import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/app_user.dart';
import '../../data/repositories/chat_repository.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ChatRepository _chatRepository = ChatRepository();
  final Rx<List<AppUser>> _users = Rx<List<AppUser>>([]);

  List<AppUser> get users => _users.value;

  @override
  void onInit() {
    super.onInit();
    _users.bindStream(usersStream());
  }

  Stream<List<AppUser>> usersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
    });
  }

  Stream<QuerySnapshot> getChatsStream(String userId) {
    return _chatRepository.getChatsStream(userId);
  }
}
