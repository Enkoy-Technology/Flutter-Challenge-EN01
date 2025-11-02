// ignore_for_file: invalid_annotation_target, file_names

import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/UserAccount.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ChatConversation.freezed.dart';
part 'ChatConversation.g.dart';

@unfreezed
class ChatConversation with _$ChatConversation {
  static lastUpdatedToTimeStamp(DateTime? dateTime) {
    return FieldValue.serverTimestamp();
  }

  static timeStampToDate(Timestamp? timeStamp) {
    if (timeStamp != null) {
      return timeStamp.toDate();
    }
    return DateTime.now();
  }

  factory ChatConversation({
    required String id,
    @JsonKey(includeToJson: false) @Default([]) List<Chat> chats,
    @JsonKey(
        toJson: ChatConversation.lastUpdatedToTimeStamp,
        fromJson: ChatConversation.timeStampToDate)
    DateTime? lastUpdatedAt,
    required List<String> participants,
    @JsonKey(includeIfNull: false) Map<String, int>? unseenMessageCount,
    @JsonKey(includeToJson: false) UserAccount? conversee,
  }) = _ChatConversation;

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationFromJson(json);
}
