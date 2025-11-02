import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String sender;
  final String text;
  final DateTime timestamp;
  final String? senderId;
  final String? recipientId;
  final String? status;

  Message({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.senderId,
    this.recipientId,
    this.status,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
      id: id,
      sender: map['sender'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      senderId: map['senderId'] as String?,
      recipientId: map['recipientId'] as String?,
      status: map['status'] as String? ?? 'sent',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      'timestamp': timestamp,
      'senderId': senderId,
      'recipientId': recipientId,
      'status': status ?? 'sent',
    };
  }
}
