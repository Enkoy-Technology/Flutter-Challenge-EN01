import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
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
        bottomNavigationBar: SingleChildScrollView(
          child: Container(
            color: kcWhite,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(
                  height: 0,
                  thickness: .5,
                ),
                kdSpace.height,
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: kdPadding),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              controller: viewModel.chatTextInputController,
                              onChanged: viewModel.onChatTextTyping,
                              decoration: InputDecoration(
                                hintText: "Type here...",
                                prefixIconConstraints: const BoxConstraints(
                                    maxHeight: 35, maxWidth: 35),
                                prefixIcon: Container(
                                  padding: const EdgeInsets.only(left: 5),
                                  margin: const EdgeInsets.only(right: 5),
                                  child: CircleAvatar(
                                      backgroundColor: kcPrimary(context),
                                      radius: 25,
                                      child: Icon(kiAdd,
                                          size: kfIconNormal,
                                          color: kcOnPrimary(context))),
                                ),
                                border: const UnderlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  borderSide:
                                      BorderSide(width: 1, color: kcLightGrey),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    borderSide: BorderSide(
                                        width: 1, color: kcLightGrey)),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  borderSide:
                                      BorderSide(width: 1, color: kcLightGrey),
                                ),
                              ),
                            ),
                          ),
                        ),
                        kdSpaceLarge.width,
                        Visibility(
                          visible:
                              viewModel.chatTextInputController.text.isNotEmpty,
                          replacement: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              decoration: BoxDecoration(
                                  color: kcPrimary(context),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: kdPaddingLarge,
                                    vertical: kdPaddingSmall),
                                child: Text(
                                  "GIF",
                                  style: kfBodyMedium(context,
                                      color: kcOnPrimary(context)),
                                ),
                              )),
                          child: InkWell(
                            onTap: viewModel.onSendChatMessage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              decoration: BoxDecoration(
                                  color: kcPrimary(context),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: kdPaddingLarge,
                                    vertical: kdPaddingSmall),
                                child: Icon(
                                  kiSend,
                                  color: kcOnPrimary(context),
                                  size: kfIconLarge,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        body: CustomScrollView(slivers: [
          AppBarWidget(
            titleWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  chatConversation.conversee!.firstName,
                  style: kfBrandStyle(context, fontWeight: FontWeight.w600),
                ),
                StreamBuilder<Map<String, dynamic>?>(
                    stream: viewModel.getConverseeOnlineStatus(),
                    builder: ((ctx, snapshot) {
                      if (snapshot.data == null || !snapshot.hasData) {
                        return Container();
                      }
                      dynamic data = snapshot.data;
                      return _renderConverseeStatus(data, context);
                    }))
              ],
            ),
            centerTitle: false,
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: kdPaddingLarge),
                child: InkWell(
                    child: Icon(
                  kiAdd,
                  size: kfIconLarge,
                )),
              )
            ],
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
                                      prevChat: i + 1 <=
                                              chatsGrouped[index].value.length -
                                                  1
                                          ? chatsGrouped[index].value[i + 1]
                                          : null,
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

  @override
  ChatConversationViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatConversationViewModel(chatConversationBase: chatConversation);

  Widget _renderConverseeStatus(data, BuildContext context) {
    if (data["isTyping"]) {
      return const TypingIndicatorWidget();
    }
    return Row(
      children: [
        CircleAvatar(radius: 2, backgroundColor: kcPrimary(context)),
        kdSpaceTiny.width,
        Text(
          "online",
          style: kfBodySmall(context),
        ),
      ],
    );
  }

  @override
  void onDispose(ChatConversationViewModel viewModel) {
    viewModel.chatTextFieldFocusNode.dispose();
    super.onDispose(viewModel);
  }
}
