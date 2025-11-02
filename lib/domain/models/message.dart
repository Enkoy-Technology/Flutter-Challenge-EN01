
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video }

class Message {
  final String messageId;
  final String senderId;
  final String senderName;
  final Timestamp timestamp;
  final String text;
  final MessageType type;
  final String? mediaUrl;
  final bool isSent;
  final bool isDelivered;

  Message({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.text = '',
    this.type = MessageType.text,
    this.mediaUrl,
    this.isSent = false,
    this.isDelivered = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp,
      'text': text,
      'type': type.toString().split('.').last,
      'mediaUrl': mediaUrl,
      'isSent': isSent,
      'isDelivered': isDelivered,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'],
      senderName: map['senderName'],
      timestamp: map['timestamp'],
      text: map['text'] ?? '',
      type: _mapStringToMessageType(map['type']),
      mediaUrl: map['mediaUrl'],
      isSent: map['isSent'] ?? false,
      isDelivered: map['isDelivered'] ?? false,
    );
  }

  static MessageType _mapStringToMessageType(String type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      default:
        return MessageType.text;
    }
  }
}
