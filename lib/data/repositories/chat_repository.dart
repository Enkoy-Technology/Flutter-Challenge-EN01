
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/models/message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
    });
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    String? text,
    XFile? mediaFile,
  }) async {
    try {
      String? mediaUrl;
      MessageType messageType = MessageType.text;

      if (mediaFile != null) {
        mediaUrl = await _uploadMedia(chatId, mediaFile);
        messageType = _getMessageTypeFromPath(mediaFile.path);
      }

      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final message = Message(
        messageId: messageRef.id,
        senderId: senderId,
        senderName: senderName,
        timestamp: Timestamp.now(),
        text: text ?? '',
        mediaUrl: mediaUrl,
        type: messageType,
        isSent: true,
      );

      await messageRef.set(message.toMap());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<String> _uploadMedia(String chatId, XFile file) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref('chats').child(chatId).child(fileName);
      await ref.putFile(File(file.path));
      return await ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error uploading media', e.toString());
      return '';
    }
  }

  MessageType _getMessageTypeFromPath(String path) {
    final extension = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return MessageType.image;
    } else if (['mp4', 'mov', 'avi'].contains(extension)) {
      return MessageType.video;
    } else {
      return MessageType.text;
    }
  }
}
