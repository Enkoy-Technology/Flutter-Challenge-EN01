import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? lastMessageSenderId;
  final int unreadCount;
  final String? createdBy;
  final DateTime createdAt;
  final String otherUserName;
  final String? otherUserPhotoUrl;
  final bool otherUserOnline;

  const ChatRoomEntity({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    this.lastMessageSenderId,
    required this.unreadCount,
    this.createdBy,
    required this.createdAt,
    required this.otherUserName,
    this.otherUserPhotoUrl,
    this.otherUserOnline = false,
  });

  @override
  List<Object?> get props => [
        id,
        participants,
        lastMessage,
        lastMessageTime,
        lastMessageSenderId,
        unreadCount,
        createdBy,
        createdAt,
        otherUserName,
        otherUserPhotoUrl,
        otherUserOnline,
      ];
}
