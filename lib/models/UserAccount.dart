// ignore_for_file: invalid_annotation_target, file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'UserAccount.freezed.dart';
part 'UserAccount.g.dart';

@freezed
class UserAccount with _$UserAccount {
  static lastUpdatedToTimeStamp(DateTime? dateTime) {
    return FieldValue.serverTimestamp();
  }

  static timeStampToDate(Timestamp? timeStamp) {
    if (timeStamp != null) {
      return timeStamp.toDate();
    }
    return DateTime.now();
  }

  factory UserAccount(
      {required String firstName,
      required String email,
      @JsonKey(includeIfNull: false) String? uid,
      @JsonKey(includeIfNull: false) String? deviceId,
      @JsonKey(includeIfNull: false) String? phoneNumber,
      @JsonKey(includeIfNull: false) String? middleName,
      @JsonKey(includeIfNull: false) String? lastName,
      @JsonKey(includeIfNull: false) String? pictureUrl,
      @JsonKey(
          toJson: UserAccount.lastUpdatedToTimeStamp,
          fromJson: UserAccount.timeStampToDate)
      DateTime? lastUpdatedAt}) = _UserAccount;

  factory UserAccount.fromJson(Map<String, dynamic> json) =>
      _$UserAccountFromJson(json);
}
