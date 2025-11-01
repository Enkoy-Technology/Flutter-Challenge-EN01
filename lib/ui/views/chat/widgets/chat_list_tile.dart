import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/utils/avatar_utils.dart';
import 'package:enkoy_chat/ui/common/utils/datetime_utils.dart';
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
                        leading: Visibility(
                            visible: !snapshot.hasData || conversee == null,
                            replacement: AvatarUtils.getAvatar(context,
                                showOutlineBorder: true,
                                color: kcPrimary(context),
                                userAccount: chatConversation.conversee!),
                            child: AvatarUtils.getAvatar(context,
                                userAccount: chatConversation.conversee!)),
                        title: Text(
                          chatConversation.conversee!.firstName,
                          style: kfBodyMedium(context,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Visibility(
                          visible: conversee != null && conversee["isTyping"],
                          replacement: Text(
                            chatConversation.chats.isNotEmpty
                                ? chatConversation.chats.last.message.text ?? ""
                                : "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: kfBodySmall(context,
                                color: kcLightGreyish(context)),
                          ),
                          child: const TypingIndicatorWidget(),
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
}
