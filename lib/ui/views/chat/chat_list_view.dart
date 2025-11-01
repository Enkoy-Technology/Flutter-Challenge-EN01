import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
import 'package:enkoy_chat/ui/common/widgets/action_button.dart';
import 'package:enkoy_chat/ui/common/widgets/app_bar_widget.dart';
import 'package:enkoy_chat/ui/common/widgets/loading_indicator.dart';
import 'package:enkoy_chat/ui/views/chat/widgets/chat_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chat_list_viewmodel.dart';

class ChatListView extends StackedView<ChatListViewModel> {
  const ChatListView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(ChatListViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback((tm) => viewModel.setUp());
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    ChatListViewModel viewModel,
    Widget? child,
  ) {
    return PopScope(
      canPop: false,
      onPopInvoked: viewModel.onPopScope,
      child: Scaffold(
          backgroundColor: kcBackground(context).withOpacity(0.95),
          body: CustomScrollView(slivers: [
            AppBarWidget(
              title: "Chats",
              automaticallyImplyLeading: false,
              actions: [
                InkWell(
                  onTap: viewModel.onTapSearch,
                  child: const Icon(kiSearch),
                ),
                InkWell(
                  onTap: viewModel.onLogout,
                  child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: kdPaddingLarge),
                      child: Icon(kiLogout)),
                ),
              ],
            ),
            SliverFillRemaining(
              child: StreamBuilder<List<ChatConversation>>(
                stream: viewModel.chatConversationStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.data == null) {
                    return const LoadingIndicator();
                  }

                  if (snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(kdSpaceXXLarge),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ((kdScreenHeight(context) * .25).round() as num)
                              .height,
                          Text(
                            "No chat conversation yet 🤠",
                            style: kfBodyLarge(context,
                                fontWeight: FontWeight.bold),
                          ),
                          kdSpaceSmall.height,
                          Text(
                            "Go search your friend and enjoy the chat.",
                            style: kfBodySmall(context),
                          ),
                          kdSpaceLarge.height,
                          AppActionButton(
                              onPressed: viewModel.onTapSearch,
                              child: const Text("Search now"))
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (ctx, index) => ChatListTile(
                          myId: viewModel.myId,
                          onlineStatusStream: viewModel
                              .getConverseeOnlineStatus(snapshot.data![index]),
                          chatConversation: snapshot.data![index],
                          onTap: viewModel.onTapConversation));
                },
              ),
            )
          ])),
    );
  }

  @override
  ChatListViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      ChatListViewModel();
}
