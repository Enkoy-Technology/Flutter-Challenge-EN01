import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeen;
  final int totalChats;

  const ProfileEntity({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
    this.totalChats = 0,
  });

  @override
  List<Object?> get props => [
        id,
        displayName,
        email,
        photoUrl,
        bio,
        isOnline,
        lastSeen,
        totalChats,
      ];
}
