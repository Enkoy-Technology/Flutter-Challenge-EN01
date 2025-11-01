import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/UserAccount.dart';
import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/utils/avatar_utils.dart';
import 'package:enkoy_chat/ui/common/utils/datetime_utils.dart';
import 'package:enkoy_chat/ui/common/widgets/app_image.dart';
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
    Color bgColor = isMyMesssage ? kcSecondary(context) : kcWhite;
    Color textColor = isMyMesssage
        ? kcOnPrimary(context).withOpacity(0.95)
        : kcOnBackground(context).withOpacity(0.75);

    final hasAttachment = chat.message.attachmentUrl != null &&
        chat.message.attachmentUrl!.isNotEmpty;
    final caption = chat.message.caption;
    final messageText = chat.message.text;

    return Container(
      constraints: BoxConstraints(
        maxWidth: kdScreenWidth(context) * .7,
        minWidth: kdScreenWidth(context) * .25,
      ),
      // remove inner padding so attachment can be edge-to-edge
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(color: bgColor, borderRadius: _getCardBorder()),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAttachment) ...[
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft:
                        Radius.circular(isMyMesssage ? kdRoundedRadius : 2),
                    topRight:
                        Radius.circular(isMyMesssage ? 2 : kdRoundedRadius),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: AppImageWidget(
                      url: chat.message.attachmentUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                if (caption != null && caption.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                        top: kdPaddingSmall,
                        left: kdPadding,
                        right: kdPaddingSmall),
                    child: Text(
                      caption,
                      style: kfBodyMedium(context, color: textColor),
                    ),
                  ),
                kdSpaceSmall.height,
              ] else ...[
                const SizedBox(height: kdPadding),
              ],
              if (messageText != null && messageText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                      top: kdPaddingSmall,
                      left: kdPadding,
                      right: kdPaddingSmall),
                  child: Text(
                    messageText,
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
                Padding(
                  padding: const EdgeInsets.only(right: kdPaddingSmall),
                  child: Text(
                    DateTimeUtils.formatTime(chat.message.createdAt!),
                    textAlign: TextAlign.right,
                    style: kfBodySmall(context, color: textColor),
                  ),
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
