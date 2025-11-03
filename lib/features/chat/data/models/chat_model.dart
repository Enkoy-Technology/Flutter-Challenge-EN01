import 'package:equatable/equatable.dart';
import 'message_model.dart';
import 'user_model.dart';

class ChatModel extends Equatable {
  final String id;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final MessageModel? lastMessage;
  final UserModel? otherUser;
  final int unreadCount;

  const ChatModel({
    required this.id,
    required this.participantIds,
    required this.createdAt,
    this.updatedAt,
    this.lastMessage,
    this.otherUser,
    this.unreadCount = 0,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      participantIds: (json['participant_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      otherUser: json['other_user'] != null
          ? UserModel.fromJson(json['other_user'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_ids': participantIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_message': lastMessage?.toJson(),
      'other_user': otherUser?.toJson(),
      'unread_count': unreadCount,
    };
  }

  ChatModel copyWith({
    String? id,
    List<String>? participantIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    MessageModel? lastMessage,
    UserModel? otherUser,
    int? unreadCount,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
      otherUser: otherUser ?? this.otherUser,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        participantIds,
        createdAt,
        updatedAt,
        lastMessage,
        otherUser,
        unreadCount,
      ];
}

