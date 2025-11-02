
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/models/app_user.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return AppUser.fromFirestore(userDoc);
    }
    return null;
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required XFile profileImage,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;

      String profileImageUrl = await _uploadProfileImage(uid, profileImage);

      AppUser newUser = AppUser(
        uid: uid,
        fullName: fullName,
        email: email,
        profileImageUrl: profileImageUrl,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toJson());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<String> _uploadProfileImage(String uid, XFile image) async {
    try {
      final ref = _storage.ref('user_photos').child(uid).child('profile.jpg');
      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error uploading profile image', e.toString());
      return '';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
