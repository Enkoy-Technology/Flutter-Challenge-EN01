import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final String? mediaUrl;
  final String status;
  final bool isRead;
  final DateTime? readAt;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.messageType,
    required this.createdAt,
    this.mediaUrl,
    this.status = 'sent',
    this.isRead = false,
    this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      mediaUrl: json['media_url'] as String?,
      status: json['status'] as String? ?? 'sent',
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String).toUtc()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'created_at': createdAt.toIso8601String(),
      'media_url': mediaUrl,
      'status': status,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? content,
    String? messageType,
    DateTime? createdAt,
    String? mediaUrl,
    String? status,
    bool? isRead,
    DateTime? readAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      createdAt: createdAt ?? this.createdAt,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    chatId,
    senderId,
    content,
    messageType,
    createdAt,
    mediaUrl,
    status,
    isRead,
    readAt,
  ];
}
