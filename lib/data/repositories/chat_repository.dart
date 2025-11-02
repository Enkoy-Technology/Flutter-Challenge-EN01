import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../domain/models/message.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromMap(doc.data()))
              .toList();
        });
  }

  Stream<DocumentSnapshot> getChatStream(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots();
  }

  Future<void> updateUserTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    await _firestore.collection('chats').doc(chatId).set({
      'typingStatus': {userId: isTyping},
    }, SetOptions(merge: true));
  }

  Future<void> markMessagesAsSeen(String chatId, String currentUserId) async {
    final querySnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('isSeen', isEqualTo: false)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return;
    }

    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'isSeen': true});
    }
    await batch.commit();
  }

  Stream<QuerySnapshot> getChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('members', arrayContains: userId)
        .orderBy('lastMessage.timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    String? text,
  }) async {
    try {
      final members = chatId.split('_');
      final otherMemberId = members.firstWhere(
        (id) => id != senderId,
        orElse: () => '',
      );

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
        mediaUrl: null,
        type: MessageType.text,
        isSent: true,
        isSeen: false,
      );

      final batch = _firestore.batch();
      batch.set(messageRef, message.toMap());
      batch.set(_firestore.collection('chats').doc(chatId), {
        'lastMessage': message.toMap(),
        'members': members,
      }, SetOptions(merge: true));
      await batch.commit();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }
}
