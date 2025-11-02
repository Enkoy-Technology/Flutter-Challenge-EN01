import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String chatRoomId;
  final String content;
  final String type; // text, image, video
  final DateTime timestamp;
  final String status; // sent, delivered, read
  final List<String> readBy; // List of user IDs who read
  final String? mediaUrl;
  final String? mediaType;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.chatRoomId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.status,
    required this.readBy,
    this.mediaUrl,
    this.mediaType,
  });

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        senderPhotoUrl,
        chatRoomId,
        content,
        type,
        timestamp,
        status,
        readBy,
        mediaUrl,
        mediaType,
      ];
}
