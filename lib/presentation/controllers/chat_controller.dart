
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/models/message.dart';

class ChatController extends GetxController {
  final Rx<List<Message>> messages = Rx<List<Message>>([]);
  final ScrollController scrollController = ScrollController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late DocumentSnapshot? lastVisible;
  bool isLoadingMore = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchInitialMessages();
  }

  void _scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent && !isLoadingMore) {
      fetchMoreMessages();
    }
  }

  void fetchInitialMessages() async {
    final snapshot = await _firestore
        .collection('chats') // Assuming a 'chats' collection
        .doc(Get.arguments) // Using chat ID from arguments
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    messages.value = snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    lastVisible = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
  }

  void fetchMoreMessages() async {
    if (lastVisible == null) return;

    isLoadingMore = true;
    final snapshot = await _firestore
        .collection('chats')
        .doc(Get.arguments)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastVisible!)
        .limit(20)
        .get();

    messages.value.addAll(snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
    lastVisible = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    isLoadingMore = false;
  }

  void sendMessage({
    required String senderId,
    required String senderName,
    String? text,
    XFile? mediaFile,
  }) async {
    String? mediaUrl;
    if (mediaFile != null) {
      final ref = _storage.ref().child('chat_media/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(mediaFile.path));
      mediaUrl = await ref.getDownloadURL();
    }

    final messageRef = _firestore
        .collection('chats')
        .doc(Get.arguments)
        .collection('messages')
        .doc();

    final message = Message(
      messageId: messageRef.id,
      senderId: senderId,
      senderName: senderName,
      text: text ?? '',
      mediaUrl: mediaUrl,
      timestamp: Timestamp.now(),
    );

    await messageRef.set(message.toMap());
  }
}
