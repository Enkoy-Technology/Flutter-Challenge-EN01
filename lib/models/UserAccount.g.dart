// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserAccount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserAccountImpl _$$UserAccountImplFromJson(Map<String, dynamic> json) =>
    _$UserAccountImpl(
      firstName: json['firstName'] as String,
      email: json['email'] as String,
      uid: json['uid'] as String?,
      deviceId: json['deviceId'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String?,
      pictureUrl: json['pictureUrl'] as String?,
      lastUpdatedAt:
          UserAccount.timeStampToDate(json['lastUpdatedAt'] as Timestamp?),
    );

Map<String, dynamic> _$$UserAccountImplToJson(_$UserAccountImpl instance) {
  final val = <String, dynamic>{
    'firstName': instance.firstName,
    'email': instance.email,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('uid', instance.uid);
  writeNotNull('deviceId', instance.deviceId);
  writeNotNull('phoneNumber', instance.phoneNumber);
  writeNotNull('middleName', instance.middleName);
  writeNotNull('lastName', instance.lastName);
  writeNotNull('pictureUrl', instance.pictureUrl);
  val['lastUpdatedAt'] =
      UserAccount.lastUpdatedToTimeStamp(instance.lastUpdatedAt);
  return val;
}
