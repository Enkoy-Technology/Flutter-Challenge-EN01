import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String fullName;
  final String email;
  final String profileImageUrl;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.profileImageUrl,
  });

  String get initials {
    if (fullName.isEmpty) return '';
    final names = fullName.split(' ');
    if (names.length > 1 && names.last.isNotEmpty) {
      return names.first[0].toUpperCase() + names.last[0].toUpperCase();
    }
    return names.first[0].toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
    );
  }
}
