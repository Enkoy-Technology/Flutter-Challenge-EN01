// ignore_for_file: invalid_annotation_target, file_names

import 'package:enkoy_chat/enums/chat_message_status.enum.dart';
import 'package:enkoy_chat/enums/chat_message_type.enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ChatMessage.freezed.dart';
part 'ChatMessage.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  static lastUpdatedToTimeStamp(DateTime? dateTime) {
    if (dateTime != null) {
      return dateTime;
    }
    return FieldValue.serverTimestamp();
  }

  static timeStampToDate(dynamic timeStamp) {
    if (timeStamp != null) {
      return timeStamp.toDate();
    }
    return DateTime.now();
  }

  factory ChatMessage(
      {@JsonKey(includeIfNull: false) String? text,
      @JsonKey(includeIfNull: false) String? attachmentUrl,
      @JsonKey(includeIfNull: false) String? caption,
      @JsonKey(includeIfNull: false) bool? isEdited,
      @JsonKey(includeIfNull: false) bool? isDeleted,
      @Default(ChatMessageStatus.sent) ChatMessageStatus status,
      @Default(ChatMessageType.text) ChatMessageType contentType,
      @JsonKey(
          toJson: ChatMessage.lastUpdatedToTimeStamp,
          fromJson: ChatMessage.timeStampToDate)
      DateTime? createdAt}) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
