import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? email;
  final String? chatId; // Add this field

  ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.email,
    this.chatId,
  });

  factory ChatUser.fromMap(Map<String, dynamic> map, String id) {
    return ChatUser(
      id: id,
      name: map['name'] ?? 'Unknown',
      avatarUrl: map['avatarUrl'],
      email: map['email'],
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? (map['lastMessageTime'] as Timestamp).toDate()
          : null,
      chatId: map['chatId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'email': email,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null
          ? Timestamp.fromDate(lastMessageTime!)
          : null,
      'chatId': chatId,
    };
  }

  // Helper method to copy with new values
  ChatUser copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    String? chatId,
  }) {
    return ChatUser(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      email: email,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      chatId: chatId ?? this.chatId,
    );
  }
}
