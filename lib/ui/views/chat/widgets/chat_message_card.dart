import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/UserAccount.dart';
import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/utils/avatar_utils.dart';
import 'package:enkoy_chat/ui/common/utils/datetime_utils.dart';
import 'package:enkoy_chat/ui/views/chat/widgets/chat_message_status_widget.dart';
import 'package:flutter/material.dart';

class ChatMessageCard extends StatelessWidget {
  final Chat? prevChat;
  final Chat chat;
  final String me;
  final UserAccount conversee;
  const ChatMessageCard(
      {super.key,
      required this.chat,
      required this.me,
      required this.conversee,
      required this.prevChat});

  bool get isMyMesssage => chat.from == me;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMyMesssage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isMyMesssage ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMyMesssage && (prevChat == null || prevChat!.from == me))
              AvatarUtils.getAvatar(context, userAccount: conversee),
            if (!isMyMesssage && !(prevChat == null || prevChat!.from == me))
              const SizedBox(
                width: 52,
              ),
            if (!isMyMesssage) kdSpaceSmall.width,
            messageContent(context)
          ],
        ),
        kdSpaceLarge.height
      ],
    );
  }

  Container messageContent(BuildContext context) {
    Color bgColor = isMyMesssage ? kcPrimary(context) : kcWhite;
    Color textColor = isMyMesssage
        ? kcOnPrimary(context).withOpacity(0.75)
        : kcOnBackground(context).withOpacity(0.75);
    return Container(
      constraints: BoxConstraints(
          maxWidth: kdScreenWidth(context) * .7,
          minWidth: kdScreenWidth(context) * .25),
      padding: const EdgeInsets.only(top: kdPadding, left: kdPadding),
      decoration: BoxDecoration(color: bgColor, borderRadius: _getCardBorder()),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kdPaddingSmall),
                child: Text(
                  chat.message.text ?? "",
                  style: kfBodyMedium(context, color: textColor),
                ),
              ),
              kdSpaceXLarge.height
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateTimeUtils.formatTime(chat.message.createdAt!),
                  textAlign: TextAlign.right,
                  style: kfBodySmall(context, color: textColor),
                ),
                Visibility(
                    visible: isMyMesssage,
                    replacement: kdSpace.width,
                    child: ChatMessageStatusWidget(
                        isMyMesssage: isMyMesssage, message: chat.message))
              ],
            ),
          )
        ],
      ),
    );
  }

  _getCardBorder() {
    return BorderRadius.only(
        topLeft: Radius.circular(isMyMesssage ? kdRoundedRadius : 2),
        bottomLeft: const Radius.circular(kdRoundedRadius),
        bottomRight: Radius.circular(isMyMesssage ? 2 : kdRoundedRadius),
        topRight: const Radius.circular(kdRoundedRadius));
  }
}
