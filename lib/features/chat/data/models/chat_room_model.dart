import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_challenge_en01/features/chat/domain/entities/chat_room_entity.dart';

class ChatRoomModel extends ChatRoomEntity {
  const ChatRoomModel({
    required super.id,
    required super.participants,
    required super.lastMessage,
    required super.lastMessageTime,
    super.lastMessageSenderId,
    required super.unreadCount,
    super.createdBy,
    required super.createdAt,
    required super.otherUserName,
    super.otherUserPhotoUrl,
    super.otherUserOnline,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      participants: List<String>.from(json['participants'] as List? ?? []),
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageTime: (json['lastMessageTime'] as Timestamp).toDate(),
      lastMessageSenderId: json['lastMessageSenderId'] as String?,
      unreadCount: json['unreadCount'] as int? ?? 0,
      createdBy: json['createdBy'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      otherUserName: json['otherUserName'] as String,
      otherUserPhotoUrl: json['otherUserPhotoUrl'] as String?,
      otherUserOnline: json['otherUserOnline'] as bool? ?? false,
    );
  }

  factory ChatRoomModel.fromEntity(ChatRoomEntity entity) {
    return ChatRoomModel(
      id: entity.id,
      participants: entity.participants,
      lastMessage: entity.lastMessage,
      lastMessageTime: entity.lastMessageTime,
      lastMessageSenderId: entity.lastMessageSenderId,
      unreadCount: entity.unreadCount,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      otherUserName: entity.otherUserName,
      otherUserPhotoUrl: entity.otherUserPhotoUrl,
      otherUserOnline: entity.otherUserOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'otherUserName': otherUserName,
      'otherUserPhotoUrl': otherUserPhotoUrl,
      'otherUserOnline': otherUserOnline,
    };
  }
}
