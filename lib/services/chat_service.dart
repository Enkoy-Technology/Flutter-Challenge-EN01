import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import 'chat_list_service.dart';

abstract class IChatService {
  Stream<List<Message>> subscribeToMessages();
  Future<void> sendMessage(String sender, String text);
}

class ChatService implements IChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _collection => _firestore.collection('messages');
  final ChatListService _chatListService = ChatListService();

  @override
  Stream<List<Message>> subscribeToMessages() {
    return _collection
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Message.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Stream<List<Message>> subscribeToChatMessages(String chatId) {
    return _collection
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) =>
              Message.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    });
  }

  @override
  Future<void> sendMessage(String sender, String text) async {
    await _collection.add({
      'sender': sender,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendChatMessage(String chatId, String senderId,
      String senderName, String text, String recipientId,
      {String? mediaUrl}) async {
    await _collection.add({
      'chatId': chatId,
      'senderId': senderId,
      'sender': senderName,
      'recipientId': recipientId,
      'text': text,
      'mediaUrl': mediaUrl ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'sent',
    });
    await _chatListService.updateChatLastMessage(chatId, text, senderId);
    await _chatListService.incrementUnreadCount(chatId, recipientId);
  }

  Future<void> updateMessageStatus(String messageId, String status) async {
    try {
      await _collection.doc(messageId).update({'status': status});
    } catch (e) {
      debugPrint('Error updating message status: $e');
    }
  }

  Future<void> markMessagesAsDelivered(
      String chatId, String recipientId) async {
    try {
      final snapshot = await _collection
          .where('chatId', isEqualTo: chatId)
          .where('recipientId', isEqualTo: recipientId)
          .where('status', isEqualTo: 'sent')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'status': 'delivered'});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking messages as delivered: $e');
    }
  }

  Future<void> markMessagesAsSeen(String chatId, String recipientId) async {
    try {
      final snapshot = await _collection
          .where('chatId', isEqualTo: chatId)
          .where('recipientId', isEqualTo: recipientId)
          .where('status', isNotEqualTo: 'seen')
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'status': 'seen'});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking messages as seen: $e');
    }
  }
}

class PlaceholderChatService implements IChatService {
  List<Message> _messages = [];
  final _controller = StreamController<List<Message>>();

  PlaceholderChatService() {
    _controller.add(_messages);
  }

  @override
  Stream<List<Message>> subscribeToMessages() => _controller.stream;

  @override
  Future<void> sendMessage(String sender, String text) async {
    _messages = List.from(_messages)
      ..add(
        Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sender: sender,
          text: text,
          timestamp: DateTime.now(),
        ),
      );
    _controller.add(_messages);
  }
}
