import 'package:enkoy_chat/enums/chat_message_type.enum.dart';
import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/utils/avatar_utils.dart';
import 'package:enkoy_chat/ui/common/utils/datetime_utils.dart';
import 'package:enkoy_chat/ui/common/widgets/app_image.dart';
import 'package:enkoy_chat/ui/views/chat/widgets/typing_indicator_widget.dart';
import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  final String myId;
  final ChatConversation chatConversation;
  final Stream<Map<String, dynamic>?> onlineStatusStream;
  final Function(ChatConversation) onTap;
  const ChatListTile(
      {super.key,
      required this.chatConversation,
      required this.onTap,
      required this.onlineStatusStream,
      required this.myId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(chatConversation);
      },
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: kdPadding),
              child: StreamBuilder<Map<String, dynamic>?>(
                  stream: onlineStatusStream,
                  builder: (context, snapshot) {
                    dynamic conversee = snapshot.data;

                    return Container(
                      color: kcBackground(context),
                      child: ListTile(
                        horizontalTitleGap: kdSpace,
                        leading: AvatarUtils.getAvatar(context,
                            isOnline: snapshot.hasData && conversee != null,
                            userAccount: chatConversation.conversee!),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chatConversation.conversee!.firstName,
                              style: kfBodyMedium(context,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (conversee == null) ...[
                              Text(
                                DateTimeUtils.getFormattedLastseenStatus(
                                  chatConversation.conversee!.lastUpdatedAt!,
                                ),
                                style: kfLabelSmall(context),
                              ),
                              kdSpaceSmall.height,
                            ]
                          ],
                        ),
                        subtitle: Visibility(
                          visible: conversee != null && conversee["isTyping"],
                          replacement: _getLastMessage(context),
                          child: TypingIndicatorWidget(
                            color: kcPrimary(context),
                          ),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(DateTimeUtils.formatTime(
                                chatConversation.lastUpdatedAt!)),
                            kdSpaceSmall.height,
                            if (chatConversation.unseenMessageCount != null &&
                                chatConversation.unseenMessageCount!
                                    .containsKey(myId))
                              Badge(
                                  label: Text(chatConversation
                                      .unseenMessageCount![myId]!
                                      .toString()))
                          ],
                        ),
                      ),
                    );
                  })),
          const Divider(
            height: .5,
          )
        ],
      ),
    );
  }

  Widget _getLastMessage(BuildContext context) {
    if (chatConversation.chats.isEmpty) {
      return const Text("");
    }
    Chat lastMessage = chatConversation.chats.last;
    if (lastMessage.message.contentType.isPicture) {
      return Row(
        children: [
          AppImageWidget(
            url: lastMessage.message.attachmentUrl ?? "",
            width: 30,
            height: 30,
          ),
          Text(lastMessage.message.caption ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: kfBodySmall(context, color: kcLightGreyish(context)))
        ],
      );
    }
    return Text(
      chatConversation.chats.isNotEmpty
          ? chatConversation.chats.last.message.contentType.isPicture
              ? 'Picture'
              : chatConversation.chats.last.message.text ?? ""
          : "",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: kfBodySmall(context, color: kcLightGreyish(context)),
    );
  }
}
