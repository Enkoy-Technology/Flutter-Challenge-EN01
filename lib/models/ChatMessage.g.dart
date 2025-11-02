// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChatMessage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      text: json['text'] as String?,
      attachmentUrl: json['attachmentUrl'] as String?,
      caption: json['caption'] as String?,
      isEdited: json['isEdited'] as bool?,
      isDeleted: json['isDeleted'] as bool?,
      status: $enumDecodeNullable(_$ChatMessageStatusEnumMap, json['status']) ??
          ChatMessageStatus.sent,
      contentType:
          $enumDecodeNullable(_$ChatMessageTypeEnumMap, json['contentType']) ??
              ChatMessageType.text,
      createdAt: ChatMessage.timeStampToDate(json['createdAt']),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('text', instance.text);
  writeNotNull('attachmentUrl', instance.attachmentUrl);
  writeNotNull('caption', instance.caption);
  writeNotNull('isEdited', instance.isEdited);
  writeNotNull('isDeleted', instance.isDeleted);
  val['status'] = _$ChatMessageStatusEnumMap[instance.status]!;
  val['contentType'] = _$ChatMessageTypeEnumMap[instance.contentType]!;
  val['createdAt'] = ChatMessage.lastUpdatedToTimeStamp(instance.createdAt);
  return val;
}

const _$ChatMessageStatusEnumMap = {
  ChatMessageStatus.sent: 'sent',
  ChatMessageStatus.delivered: 'delivered',
  ChatMessageStatus.seen: 'seen',
};

const _$ChatMessageTypeEnumMap = {
  ChatMessageType.text: 'text',
  ChatMessageType.audio: 'audio',
  ChatMessageType.video: 'video',
  ChatMessageType.picture: 'picture',
};
