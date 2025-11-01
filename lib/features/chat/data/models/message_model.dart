import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.text,
    super.type,
    super.mediaUrl,
    required super.timestamp,
    super.isRead,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      type: data['type'] ?? 'text',
      mediaUrl: data['mediaUrl'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'type': type,
      'mediaUrl': mediaUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}


