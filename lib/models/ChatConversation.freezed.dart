// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ChatConversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatConversation _$ChatConversationFromJson(Map<String, dynamic> json) {
  return _ChatConversation.fromJson(json);
}

/// @nodoc
mixin _$ChatConversation {
  String get id => throw _privateConstructorUsedError;
  set id(String value) => throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false)
  List<Chat> get chats => throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false)
  set chats(List<Chat> value) => throw _privateConstructorUsedError;
  @JsonKey(
      toJson: ChatConversation.lastUpdatedToTimeStamp,
      fromJson: ChatConversation.timeStampToDate)
  DateTime? get lastUpdatedAt => throw _privateConstructorUsedError;
  @JsonKey(
      toJson: ChatConversation.lastUpdatedToTimeStamp,
      fromJson: ChatConversation.timeStampToDate)
  set lastUpdatedAt(DateTime? value) => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  set participants(List<String> value) => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  Map<String, int>? get unseenMessageCount =>
      throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  set unseenMessageCount(Map<String, int>? value) =>
      throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false)
  UserAccount? get conversee => throw _privateConstructorUsedError;
  @JsonKey(includeToJson: false)
  set conversee(UserAccount? value) => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatConversationCopyWith<ChatConversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatConversationCopyWith<$Res> {
  factory $ChatConversationCopyWith(
          ChatConversation value, $Res Function(ChatConversation) then) =
      _$ChatConversationCopyWithImpl<$Res, ChatConversation>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(includeToJson: false) List<Chat> chats,
      @JsonKey(
          toJson: ChatConversation.lastUpdatedToTimeStamp,
          fromJson: ChatConversation.timeStampToDate)
      DateTime? lastUpdatedAt,
      List<String> participants,
      @JsonKey(includeIfNull: false) Map<String, int>? unseenMessageCount,
      @JsonKey(includeToJson: false) UserAccount? conversee});

  $UserAccountCopyWith<$Res>? get conversee;
}

/// @nodoc
class _$ChatConversationCopyWithImpl<$Res, $Val extends ChatConversation>
    implements $ChatConversationCopyWith<$Res> {
  _$ChatConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chats = null,
    Object? lastUpdatedAt = freezed,
    Object? participants = null,
    Object? unseenMessageCount = freezed,
    Object? conversee = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chats: null == chats
          ? _value.chats
          : chats // ignore: cast_nullable_to_non_nullable
              as List<Chat>,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      unseenMessageCount: freezed == unseenMessageCount
          ? _value.unseenMessageCount
          : unseenMessageCount // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      conversee: freezed == conversee
          ? _value.conversee
          : conversee // ignore: cast_nullable_to_non_nullable
              as UserAccount?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserAccountCopyWith<$Res>? get conversee {
    if (_value.conversee == null) {
      return null;
    }

    return $UserAccountCopyWith<$Res>(_value.conversee!, (value) {
      return _then(_value.copyWith(conversee: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatConversationImplCopyWith<$Res>
    implements $ChatConversationCopyWith<$Res> {
  factory _$$ChatConversationImplCopyWith(_$ChatConversationImpl value,
          $Res Function(_$ChatConversationImpl) then) =
      __$$ChatConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(includeToJson: false) List<Chat> chats,
      @JsonKey(
          toJson: ChatConversation.lastUpdatedToTimeStamp,
          fromJson: ChatConversation.timeStampToDate)
      DateTime? lastUpdatedAt,
      List<String> participants,
      @JsonKey(includeIfNull: false) Map<String, int>? unseenMessageCount,
      @JsonKey(includeToJson: false) UserAccount? conversee});

  @override
  $UserAccountCopyWith<$Res>? get conversee;
}

/// @nodoc
class __$$ChatConversationImplCopyWithImpl<$Res>
    extends _$ChatConversationCopyWithImpl<$Res, _$ChatConversationImpl>
    implements _$$ChatConversationImplCopyWith<$Res> {
  __$$ChatConversationImplCopyWithImpl(_$ChatConversationImpl _value,
      $Res Function(_$ChatConversationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chats = null,
    Object? lastUpdatedAt = freezed,
    Object? participants = null,
    Object? unseenMessageCount = freezed,
    Object? conversee = freezed,
  }) {
    return _then(_$ChatConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chats: null == chats
          ? _value.chats
          : chats // ignore: cast_nullable_to_non_nullable
              as List<Chat>,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      unseenMessageCount: freezed == unseenMessageCount
          ? _value.unseenMessageCount
          : unseenMessageCount // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      conversee: freezed == conversee
          ? _value.conversee
          : conversee // ignore: cast_nullable_to_non_nullable
              as UserAccount?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatConversationImpl implements _ChatConversation {
  _$ChatConversationImpl(
      {required this.id,
      @JsonKey(includeToJson: false) this.chats = const [],
      @JsonKey(
          toJson: ChatConversation.lastUpdatedToTimeStamp,
          fromJson: ChatConversation.timeStampToDate)
      this.lastUpdatedAt,
      required this.participants,
      @JsonKey(includeIfNull: false) this.unseenMessageCount,
      @JsonKey(includeToJson: false) this.conversee});

  factory _$ChatConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatConversationImplFromJson(json);

  @override
  String id;
  @override
  @JsonKey(includeToJson: false)
  List<Chat> chats;
  @override
  @JsonKey(
      toJson: ChatConversation.lastUpdatedToTimeStamp,
      fromJson: ChatConversation.timeStampToDate)
  DateTime? lastUpdatedAt;
  @override
  List<String> participants;
  @override
  @JsonKey(includeIfNull: false)
  Map<String, int>? unseenMessageCount;
  @override
  @JsonKey(includeToJson: false)
  UserAccount? conversee;

  @override
  String toString() {
    return 'ChatConversation(id: $id, chats: $chats, lastUpdatedAt: $lastUpdatedAt, participants: $participants, unseenMessageCount: $unseenMessageCount, conversee: $conversee)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatConversationImplCopyWith<_$ChatConversationImpl> get copyWith =>
      __$$ChatConversationImplCopyWithImpl<_$ChatConversationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatConversationImplToJson(
      this,
    );
  }
}

abstract class _ChatConversation implements ChatConversation {
  factory _ChatConversation(
          {required String id,
          @JsonKey(includeToJson: false) List<Chat> chats,
          @JsonKey(
              toJson: ChatConversation.lastUpdatedToTimeStamp,
              fromJson: ChatConversation.timeStampToDate)
          DateTime? lastUpdatedAt,
          required List<String> participants,
          @JsonKey(includeIfNull: false) Map<String, int>? unseenMessageCount,
          @JsonKey(includeToJson: false) UserAccount? conversee}) =
      _$ChatConversationImpl;

  factory _ChatConversation.fromJson(Map<String, dynamic> json) =
      _$ChatConversationImpl.fromJson;

  @override
  String get id;
  set id(String value);
  @override
  @JsonKey(includeToJson: false)
  List<Chat> get chats;
  @JsonKey(includeToJson: false)
  set chats(List<Chat> value);
  @override
  @JsonKey(
      toJson: ChatConversation.lastUpdatedToTimeStamp,
      fromJson: ChatConversation.timeStampToDate)
  DateTime? get lastUpdatedAt;
  @JsonKey(
      toJson: ChatConversation.lastUpdatedToTimeStamp,
      fromJson: ChatConversation.timeStampToDate)
  set lastUpdatedAt(DateTime? value);
  @override
  List<String> get participants;
  set participants(List<String> value);
  @override
  @JsonKey(includeIfNull: false)
  Map<String, int>? get unseenMessageCount;
  @JsonKey(includeIfNull: false)
  set unseenMessageCount(Map<String, int>? value);
  @override
  @JsonKey(includeToJson: false)
  UserAccount? get conversee;
  @JsonKey(includeToJson: false)
  set conversee(UserAccount? value);
  @override
  @JsonKey(ignore: true)
  _$$ChatConversationImplCopyWith<_$ChatConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
