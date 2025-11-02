import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    super.senderPhotoUrl,
    required super.chatRoomId,
    required super.content,
    required super.type,
    required super.timestamp,
    required super.status,
    required super.readBy,
    super.mediaUrl,
    super.mediaType,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderPhotoUrl: json['senderPhotoUrl'] as String?,
      chatRoomId: json['chatRoomId'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      status: json['status'] as String? ?? 'sent',
      readBy: List<String>.from(json['readBy'] as List? ?? []),
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
    );
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id,
      senderId: entity.senderId,
      senderName: entity.senderName,
      senderPhotoUrl: entity.senderPhotoUrl,
      chatRoomId: entity.chatRoomId,
      content: entity.content,
      type: entity.type,
      timestamp: entity.timestamp,
      status: entity.status,
      readBy: entity.readBy,
      mediaUrl: entity.mediaUrl,
      mediaType: entity.mediaType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'chatRoomId': chatRoomId,
      'content': content,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'readBy': readBy,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
    };
  }
}
