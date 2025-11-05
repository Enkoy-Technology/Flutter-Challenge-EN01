import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    super.avatarUrl,
    super.isOnline,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      avatarUrl: data['avatarUrl'],
      isOnline: data['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
    };
  }
}