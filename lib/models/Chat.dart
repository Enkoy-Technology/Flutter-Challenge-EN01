// ignore_for_file: invalid_annotation_target, file_names

import 'package:enkoy_chat/models/ChatMessage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'Chat.freezed.dart';
part 'Chat.g.dart';

@freezed
class Chat with _$Chat {
  factory Chat({
    required String from,
    @JsonKey(includeIfNull: true) String? id,
    required ChatMessage message,
  }) = _Chat;

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
}
