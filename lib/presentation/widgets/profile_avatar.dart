import 'package:flutter/material.dart';
import '../../domain/models/app_user.dart';

class ProfileAvatar extends StatelessWidget {
  final AppUser user;
  final double radius;

  const ProfileAvatar({super.key, required this.user, this.radius = 24.0});

  @override
  Widget build(BuildContext context) {
    final hasImage = user.profileImageUrl.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundImage: hasImage ? NetworkImage(user.profileImageUrl) : null,
      child: !hasImage
          ? Text(user.initials, style: TextStyle(fontSize: radius * 0.8))
          : null,
    );
  }
}
