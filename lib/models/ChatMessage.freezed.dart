// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ChatMessage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  @JsonKey(includeIfNull: false)
  String? get text => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get attachmentUrl => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get caption => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  bool? get isEdited => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  bool? get isDeleted => throw _privateConstructorUsedError;
  ChatMessageStatus get status => throw _privateConstructorUsedError;
  ChatMessageType get contentType => throw _privateConstructorUsedError;
  @JsonKey(
      toJson: ChatMessage.lastUpdatedToTimeStamp,
      fromJson: ChatMessage.timeStampToDate)
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call(
      {@JsonKey(includeIfNull: false) String? text,
      @JsonKey(includeIfNull: false) String? attachmentUrl,
      @JsonKey(includeIfNull: false) String? caption,
      @JsonKey(includeIfNull: false) bool? isEdited,
      @JsonKey(includeIfNull: false) bool? isDeleted,
      ChatMessageStatus status,
      ChatMessageType contentType,
      @JsonKey(
          toJson: ChatMessage.lastUpdatedToTimeStamp,
          fromJson: ChatMessage.timeStampToDate)
      DateTime? createdAt});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = freezed,
    Object? attachmentUrl = freezed,
    Object? caption = freezed,
    Object? isEdited = freezed,
    Object? isDeleted = freezed,
    Object? status = null,
    Object? contentType = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentUrl: freezed == attachmentUrl
          ? _value.attachmentUrl
          : attachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      isEdited: freezed == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool?,
      isDeleted: freezed == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChatMessageStatus,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as ChatMessageType,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(includeIfNull: false) String? text,
      @JsonKey(includeIfNull: false) String? attachmentUrl,
      @JsonKey(includeIfNull: false) String? caption,
      @JsonKey(includeIfNull: false) bool? isEdited,
      @JsonKey(includeIfNull: false) bool? isDeleted,
      ChatMessageStatus status,
      ChatMessageType contentType,
      @JsonKey(
          toJson: ChatMessage.lastUpdatedToTimeStamp,
          fromJson: ChatMessage.timeStampToDate)
      DateTime? createdAt});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = freezed,
    Object? attachmentUrl = freezed,
    Object? caption = freezed,
    Object? isEdited = freezed,
    Object? isDeleted = freezed,
    Object? status = null,
    Object? contentType = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$ChatMessageImpl(
      text: freezed == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      attachmentUrl: freezed == attachmentUrl
          ? _value.attachmentUrl
          : attachmentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      isEdited: freezed == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool?,
      isDeleted: freezed == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ChatMessageStatus,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as ChatMessageType,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  _$ChatMessageImpl(
      {@JsonKey(includeIfNull: false) this.text,
      @JsonKey(includeIfNull: false) this.attachmentUrl,
      @JsonKey(includeIfNull: false) this.caption,
      @JsonKey(includeIfNull: false) this.isEdited,
      @JsonKey(includeIfNull: false) this.isDeleted,
      this.status = ChatMessageStatus.sent,
      this.contentType = ChatMessageType.text,
      @JsonKey(
          toJson: ChatMessage.lastUpdatedToTimeStamp,
          fromJson: ChatMessage.timeStampToDate)
      this.createdAt});

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  @JsonKey(includeIfNull: false)
  final String? text;
  @override
  @JsonKey(includeIfNull: false)
  final String? attachmentUrl;
  @override
  @JsonKey(includeIfNull: false)
  final String? caption;
  @override
  @JsonKey(includeIfNull: false)
  final bool? isEdited;
  @override
  @JsonKey(includeIfNull: false)
  final bool? isDeleted;
  @override
  @JsonKey()
  final ChatMessageStatus status;
  @override
  @JsonKey()
  final ChatMessageType contentType;
  @override
  @JsonKey(
      toJson: ChatMessage.lastUpdatedToTimeStamp,
      fromJson: ChatMessage.timeStampToDate)
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ChatMessage(text: $text, attachmentUrl: $attachmentUrl, caption: $caption, isEdited: $isEdited, isDeleted: $isDeleted, status: $status, contentType: $contentType, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.attachmentUrl, attachmentUrl) ||
                other.attachmentUrl == attachmentUrl) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, text, attachmentUrl, caption,
      isEdited, isDeleted, status, contentType, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  factory _ChatMessage(
      {@JsonKey(includeIfNull: false) final String? text,
      @JsonKey(includeIfNull: false) final String? attachmentUrl,
      @JsonKey(includeIfNull: false) final String? caption,
      @JsonKey(includeIfNull: false) final bool? isEdited,
      @JsonKey(includeIfNull: false) final bool? isDeleted,
      final ChatMessageStatus status,
      final ChatMessageType contentType,
      @JsonKey(
          toJson: ChatMessage.lastUpdatedToTimeStamp,
          fromJson: ChatMessage.timeStampToDate)
      final DateTime? createdAt}) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  @JsonKey(includeIfNull: false)
  String? get text;
  @override
  @JsonKey(includeIfNull: false)
  String? get attachmentUrl;
  @override
  @JsonKey(includeIfNull: false)
  String? get caption;
  @override
  @JsonKey(includeIfNull: false)
  bool? get isEdited;
  @override
  @JsonKey(includeIfNull: false)
  bool? get isDeleted;
  @override
  ChatMessageStatus get status;
  @override
  ChatMessageType get contentType;
  @override
  @JsonKey(
      toJson: ChatMessage.lastUpdatedToTimeStamp,
      fromJson: ChatMessage.timeStampToDate)
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
