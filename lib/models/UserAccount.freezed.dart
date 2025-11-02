// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'UserAccount.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserAccount _$UserAccountFromJson(Map<String, dynamic> json) {
  return _UserAccount.fromJson(json);
}

/// @nodoc
mixin _$UserAccount {
  String get firstName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get uid => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get deviceId => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get middleName => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(includeIfNull: false)
  String? get pictureUrl => throw _privateConstructorUsedError;
  @JsonKey(
      toJson: UserAccount.lastUpdatedToTimeStamp,
      fromJson: UserAccount.timeStampToDate)
  DateTime? get lastUpdatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserAccountCopyWith<UserAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserAccountCopyWith<$Res> {
  factory $UserAccountCopyWith(
          UserAccount value, $Res Function(UserAccount) then) =
      _$UserAccountCopyWithImpl<$Res, UserAccount>;
  @useResult
  $Res call(
      {String firstName,
      String email,
      @JsonKey(includeIfNull: false) String? uid,
      @JsonKey(includeIfNull: false) String? deviceId,
      @JsonKey(includeIfNull: false) String? phoneNumber,
      @JsonKey(includeIfNull: false) String? middleName,
      @JsonKey(includeIfNull: false) String? lastName,
      @JsonKey(includeIfNull: false) String? pictureUrl,
      @JsonKey(
          toJson: UserAccount.lastUpdatedToTimeStamp,
          fromJson: UserAccount.timeStampToDate)
      DateTime? lastUpdatedAt});
}

/// @nodoc
class _$UserAccountCopyWithImpl<$Res, $Val extends UserAccount>
    implements $UserAccountCopyWith<$Res> {
  _$UserAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? email = null,
    Object? uid = freezed,
    Object? deviceId = freezed,
    Object? phoneNumber = freezed,
    Object? middleName = freezed,
    Object? lastName = freezed,
    Object? pictureUrl = freezed,
    Object? lastUpdatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      middleName: freezed == middleName
          ? _value.middleName
          : middleName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      pictureUrl: freezed == pictureUrl
          ? _value.pictureUrl
          : pictureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserAccountImplCopyWith<$Res>
    implements $UserAccountCopyWith<$Res> {
  factory _$$UserAccountImplCopyWith(
          _$UserAccountImpl value, $Res Function(_$UserAccountImpl) then) =
      __$$UserAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String firstName,
      String email,
      @JsonKey(includeIfNull: false) String? uid,
      @JsonKey(includeIfNull: false) String? deviceId,
      @JsonKey(includeIfNull: false) String? phoneNumber,
      @JsonKey(includeIfNull: false) String? middleName,
      @JsonKey(includeIfNull: false) String? lastName,
      @JsonKey(includeIfNull: false) String? pictureUrl,
      @JsonKey(
          toJson: UserAccount.lastUpdatedToTimeStamp,
          fromJson: UserAccount.timeStampToDate)
      DateTime? lastUpdatedAt});
}

/// @nodoc
class __$$UserAccountImplCopyWithImpl<$Res>
    extends _$UserAccountCopyWithImpl<$Res, _$UserAccountImpl>
    implements _$$UserAccountImplCopyWith<$Res> {
  __$$UserAccountImplCopyWithImpl(
      _$UserAccountImpl _value, $Res Function(_$UserAccountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? email = null,
    Object? uid = freezed,
    Object? deviceId = freezed,
    Object? phoneNumber = freezed,
    Object? middleName = freezed,
    Object? lastName = freezed,
    Object? pictureUrl = freezed,
    Object? lastUpdatedAt = freezed,
  }) {
    return _then(_$UserAccountImpl(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      uid: freezed == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      middleName: freezed == middleName
          ? _value.middleName
          : middleName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      pictureUrl: freezed == pictureUrl
          ? _value.pictureUrl
          : pictureUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdatedAt: freezed == lastUpdatedAt
          ? _value.lastUpdatedAt
          : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserAccountImpl implements _UserAccount {
  _$UserAccountImpl(
      {required this.firstName,
      required this.email,
      @JsonKey(includeIfNull: false) this.uid,
      @JsonKey(includeIfNull: false) this.deviceId,
      @JsonKey(includeIfNull: false) this.phoneNumber,
      @JsonKey(includeIfNull: false) this.middleName,
      @JsonKey(includeIfNull: false) this.lastName,
      @JsonKey(includeIfNull: false) this.pictureUrl,
      @JsonKey(
          toJson: UserAccount.lastUpdatedToTimeStamp,
          fromJson: UserAccount.timeStampToDate)
      this.lastUpdatedAt});

  factory _$UserAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserAccountImplFromJson(json);

  @override
  final String firstName;
  @override
  final String email;
  @override
  @JsonKey(includeIfNull: false)
  final String? uid;
  @override
  @JsonKey(includeIfNull: false)
  final String? deviceId;
  @override
  @JsonKey(includeIfNull: false)
  final String? phoneNumber;
  @override
  @JsonKey(includeIfNull: false)
  final String? middleName;
  @override
  @JsonKey(includeIfNull: false)
  final String? lastName;
  @override
  @JsonKey(includeIfNull: false)
  final String? pictureUrl;
  @override
  @JsonKey(
      toJson: UserAccount.lastUpdatedToTimeStamp,
      fromJson: UserAccount.timeStampToDate)
  final DateTime? lastUpdatedAt;

  @override
  String toString() {
    return 'UserAccount(firstName: $firstName, email: $email, uid: $uid, deviceId: $deviceId, phoneNumber: $phoneNumber, middleName: $middleName, lastName: $lastName, pictureUrl: $pictureUrl, lastUpdatedAt: $lastUpdatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserAccountImpl &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.middleName, middleName) ||
                other.middleName == middleName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.pictureUrl, pictureUrl) ||
                other.pictureUrl == pictureUrl) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, firstName, email, uid, deviceId,
      phoneNumber, middleName, lastName, pictureUrl, lastUpdatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserAccountImplCopyWith<_$UserAccountImpl> get copyWith =>
      __$$UserAccountImplCopyWithImpl<_$UserAccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserAccountImplToJson(
      this,
    );
  }
}

abstract class _UserAccount implements UserAccount {
  factory _UserAccount(
      {required final String firstName,
      required final String email,
      @JsonKey(includeIfNull: false) final String? uid,
      @JsonKey(includeIfNull: false) final String? deviceId,
      @JsonKey(includeIfNull: false) final String? phoneNumber,
      @JsonKey(includeIfNull: false) final String? middleName,
      @JsonKey(includeIfNull: false) final String? lastName,
      @JsonKey(includeIfNull: false) final String? pictureUrl,
      @JsonKey(
          toJson: UserAccount.lastUpdatedToTimeStamp,
          fromJson: UserAccount.timeStampToDate)
      final DateTime? lastUpdatedAt}) = _$UserAccountImpl;

  factory _UserAccount.fromJson(Map<String, dynamic> json) =
      _$UserAccountImpl.fromJson;

  @override
  String get firstName;
  @override
  String get email;
  @override
  @JsonKey(includeIfNull: false)
  String? get uid;
  @override
  @JsonKey(includeIfNull: false)
  String? get deviceId;
  @override
  @JsonKey(includeIfNull: false)
  String? get phoneNumber;
  @override
  @JsonKey(includeIfNull: false)
  String? get middleName;
  @override
  @JsonKey(includeIfNull: false)
  String? get lastName;
  @override
  @JsonKey(includeIfNull: false)
  String? get pictureUrl;
  @override
  @JsonKey(
      toJson: UserAccount.lastUpdatedToTimeStamp,
      fromJson: UserAccount.timeStampToDate)
  DateTime? get lastUpdatedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserAccountImplCopyWith<_$UserAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
