
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/user.dart' as um;

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Rx<List<um.User>> _users = Rx<List<um.User>>([]);

  List<um.User> get users => _users.value;

  @override
  void onInit() {
    super.onInit();
    _users.bindStream(usersStream());
  }

  Stream<List<um.User>> usersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => um.User.fromMap(doc.data())).toList();
    });
  }
}
