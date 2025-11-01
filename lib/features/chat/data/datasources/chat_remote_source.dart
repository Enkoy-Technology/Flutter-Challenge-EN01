import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/features/chat/data/models/chat_user.dart';
import '../models/message_model.dart';

class ChatRemoteSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  Stream<List<ChatUser>> getAllUsers(String currentUserId) {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserId) // exclude current user
          .map((doc) => ChatUser.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
