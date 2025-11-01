import 'package:enkoy_chat/enums/chat_message_status.enum.dart';
import 'package:enkoy_chat/models/ChatMessage.dart';
import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
import 'package:flutter/material.dart';

class ChatMessageStatusWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isMyMesssage;
  final Color? color;
  const ChatMessageStatusWidget(
      {super.key,
      required this.isMyMesssage,
      required this.message,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: kdPaddingSmall),
      child: SizedBox(
        width: 25,
        child: Stack(
          children: [
            kdSpaceLarge.width,
            Icon(
              kiCheck,
              size: kfIconSmall,
              color: color ?? kcOnPrimary(context).withOpacity(0.75),
            ),
            if (message.status.isSeen)
              Positioned(
                right: 5,
                child: Icon(
                  kiCheck,
                  size: kfIconSmall,
                  color: color ?? kcOnPrimary(context).withOpacity(0.75),
                ),
              )
          ],
        ),
      ),
    );
  }
}
