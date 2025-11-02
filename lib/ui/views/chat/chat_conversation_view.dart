import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
import 'package:enkoy_chat/ui/common/utils/avatar_utils.dart';
import 'package:enkoy_chat/ui/common/utils/datetime_utils.dart';
import 'package:enkoy_chat/ui/common/widgets/app_bar_widget.dart';
import 'package:enkoy_chat/ui/common/widgets/loading_indicator.dart';
import 'package:enkoy_chat/ui/views/chat/widgets/chat_message_card.dart';
import 'package:enkoy_chat/ui/views/chat/widgets/typing_indicator_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chat_conversation_viewmodel.dart';

class ChatConversationView extends StackedView<ChatConversationViewModel> {
  final ChatConversation chatConversation;
  const ChatConversationView({Key? key, required this.chatConversation})
      : super(key: key);

  @override
  void onViewModelReady(ChatConversationViewModel viewModel) {
    viewModel.setUp();
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    ChatConversationViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
        backgroundColor: kcBackground(context).withOpacity(0.95),
        bottomNavigationBar: viewModel.isBusy
            ? const LoadingIndicator()
            : SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    color: kcWhite,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Divider(height: 0, thickness: .5),
                        kdSpace.height,
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: kdPadding),
                          child: Row(
                            children: [
                              // Emoticon / add circle
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kcXVeryLightGreyish(context)),
                                child: const Icon(kiEmoji,
                                    size: kfIconNormal, color: kcGrey),
                              ),
                              kdSpace.width,

                              // Text input area
                              Expanded(
                                flex: 65,
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: kcWhite,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: kcLightGrey),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              viewModel.chatTextInputController,
                                          focusNode:
                                              viewModel.chatTextFieldFocusNode,
                                          onChanged: viewModel.onChatTextTyping,
                                          decoration: const InputDecoration(
                                            hintText: 'Message...',
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: kdPadding,
                                                    vertical: 12),
                                          ),
                                        ),
                                      ),
                                      // Microphone icon inside input
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Visibility(
                                          visible: viewModel
                                              .chatTextInputController
                                              .text
                                              .isEmpty,
                                          replacement: IconButton(
                                            onPressed:
                                                viewModel.onSendChatMessage,
                                            icon: Icon(kiSend,
                                                color: kcPrimary(context)),
                                            splashRadius: 20,
                                          ),
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(kiMic,
                                                color: kcGrey),
                                            splashRadius: 20,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 30,
                                child: Row(
                                  children: [
                                    kdSpace.width,
                                    // Camera and gallery icons
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => viewModel
                                              .onCaptureFromCamera(context),
                                          child: Icon(kiCamera,
                                              color: kcLightGreyish(context)),
                                        ),
                                        kdSpace.width,
                                        InkWell(
                                          onTap: () =>
                                              viewModel.onPickImage(context),
                                          child: Icon(kiPhotoAlbum,
                                              color: kcLightGreyish(context)),
                                        ),
                                        kdSpace.width,
                                        InkWell(
                                          onTap: () {},
                                          child: Icon(kiAdd,
                                              color: kcLightGreyish(context)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
        body: CustomScrollView(slivers: [
          AppBarWidget(
            leading: GestureDetector(
                onTap: viewModel.onBack,
                child: Icon(kiArrowBack, color: kcOnPrimary(context))),
            titleWidget: _converseeAvatar(viewModel, context),
            centerTitle: false,
            actions: const [],
          ),
          SliverFillRemaining(
            child: StreamBuilder<List<Chat>>(
              stream: viewModel.getChatStream(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  //snapshot.connectionState == ConnectionState.waiting ||
                  return const LoadingIndicator();
                }
                List<Chat> chats = snapshot.data ?? [];
                List<MapEntry<String, List<Chat>>> chatsGrouped =
                    viewModel.getGroupedChats(chats);
                viewModel.refreshLoadedChats(chats);
                return ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.zero,
                    itemCount: chatsGrouped.length,
                    itemBuilder: (ctx, index) {
                      return Padding(
                        padding: const EdgeInsets.all(kdPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                                child: SizedBox(
                              width: kdScreenWidth(context),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 30,
                                    child: Divider(
                                      thickness: 2,
                                      color: kcXVeryLightGreyish(context),
                                    ),
                                  ),
                                  kdSpace.width,
                                  Text(
                                    chatsGrouped[index].key,
                                    style: kfBodyMedium(context,
                                        color: kcLightGreyish(context)),
                                  ),
                                  kdSpace.width,
                                  Expanded(
                                      flex: 30,
                                      child: Divider(
                                        thickness: 2,
                                        color: kcXVeryLightGreyish(context),
                                      )),
                                ],
                              ),
                            )),
                            kdSpaceLarge.height,
                            ...List<Widget>.from(chatsGrouped[index]
                                .value
                                .mapIndexed((i, chat) => ChatMessageCard(
                                      chat: chat,
                                      conversee: chatConversation.conversee!,
                                      me: viewModel.myEmail,
                                    ))).reversed
                          ],
                        ),
                      );
                    });
              },
            ),
          )
        ]));
  }

  StreamBuilder<Map<String, dynamic>?> _converseeAvatar(
      ChatConversationViewModel viewModel, BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
        stream: viewModel.getConverseeOnlineStatus(),
        builder: ((ctx, snapshot) {
          dynamic data = snapshot.data;
          return Row(
            children: [
              AvatarUtils.getAvatar(
                context,
                userAccount: chatConversation.conversee!,
                isOnline: snapshot.data != null && snapshot.hasData,
                radius: 18,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatConversation.conversee!.firstName,
                    style: kfBrandStyle(context,
                        fontWeight: FontWeight.w600,
                        color: kcOnPrimary(context)),
                  ),
                  if (snapshot.hasData && snapshot.data != null) ...[
                    _renderConverseeStatus(data, context)
                  ] else ...[
                    Text(
                      DateTimeUtils.getFormattedLastseenStatus(
                          chatConversation.conversee!.lastUpdatedAt!),
                      style: kfBodySmall(context, color: kcOnPrimary(context)),
                    )
                  ]
                ],
              )
            ],
          );
        }));
  }

  @override
  ChatConversationViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatConversationViewModel(chatConversationBase: chatConversation);

  Widget _renderConverseeStatus(data, BuildContext context) {
    if (data["isTyping"]) {
      return const TypingIndicatorWidget();
    }
    return Text(
      "online",
      style: kfBodySmall(context, color: kcOnPrimary(context)),
    );
  }

  @override
  void onDispose(ChatConversationViewModel viewModel) {
    viewModel.chatTextFieldFocusNode.dispose();
    super.onDispose(viewModel);
  }
}
