import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? email;
  final String? chatId;
  final bool? isOnline;
  final int unreadCount;
  final bool isTyping;

  ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.email,
    this.chatId,
    this.isOnline,
    this.unreadCount = 0,
    this.isTyping = false,
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
      isOnline: map['isOnline'] ?? false,
    );
  }

  ChatUser copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    String? chatId,
    bool? isOnline,
    int? unreadCount,
    bool? isTyping,
  }) {
    return ChatUser(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      email: email,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      chatId: chatId ?? this.chatId,
      isOnline: isOnline ?? this.isOnline,
      unreadCount: unreadCount ?? this.unreadCount,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}
