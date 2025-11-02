import 'dart:convert';
import 'package:enkoy_chat/models/UserAccount.dart';
import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/widgets/app_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class AvatarUtils {
  static final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.brown,
    Colors.deepOrange
  ];
  static getAvatarColorFromName(String name) {
    return colors[_getAvatarId(name)];
  }

  static int _getAvatarId(String name) {
    try {
      return (const AsciiEncoder().convert(name).sumBy((e) => e) % 5);
    } catch (e) {
      return 0;
    }
  }

  static Widget getAvatar(
    BuildContext context, {
    required UserAccount userAccount,
    Color? color,
    double radius = 25,
    bool isOnline = false,
    TextStyle? textStyle,
  }) {
    String thumbnail = userAccount.firstName[0];

    Widget avatar = CircleAvatar(
      radius: radius - 2,
      backgroundColor:
          AvatarUtils.getAvatarColorFromName(userAccount.firstName),
      child: Text(thumbnail,
          style: textStyle ?? kfBodyLarge(context, color: kcWhite)),
    );
    if (userAccount.pictureUrl != null) {
      avatar = Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipOval(
            child: AppImageWidget(
          url: userAccount.pictureUrl!,
          width: radius * 2,
          height: radius * 2,
        )),
      );
    }

    return Stack(
      children: [
        avatar,
        Positioned(
            left: 0,
            bottom: 7,
            child: CircleAvatar(
              backgroundColor: kcWhite,
              radius: radius * .25,
              child: CircleAvatar(
                radius: radius * .2,
                backgroundColor: isOnline ? kcGreen : kcRed,
              ),
            ))
      ],
    );
  }
}
