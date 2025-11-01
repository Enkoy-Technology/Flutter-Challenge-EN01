// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChatConversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatConversationImpl _$$ChatConversationImplFromJson(
        Map<String, dynamic> json) =>
    _$ChatConversationImpl(
      id: json['id'] as String,
      chats: (json['chats'] as List<dynamic>?)
              ?.map((e) => Chat.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastUpdatedAt:
          ChatConversation.timeStampToDate(json['lastUpdatedAt'] as Timestamp?),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      unseenMessageCount:
          (json['unseenMessageCount'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      conversee: json['conversee'] == null
          ? null
          : UserAccount.fromJson(json['conversee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ChatConversationImplToJson(
    _$ChatConversationImpl instance) {
  final val = <String, dynamic>{
    'id': instance.id,
    'lastUpdatedAt':
        ChatConversation.lastUpdatedToTimeStamp(instance.lastUpdatedAt),
    'participants': instance.participants,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('unseenMessageCount', instance.unseenMessageCount);
  return val;
}
