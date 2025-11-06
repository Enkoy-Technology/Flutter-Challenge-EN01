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
          floatingActionButton: FloatingActionButton(
            onPressed: viewModel.onAddChat,
            backgroundColor: kcSecondary(context),
            child: Icon(kiAdd, color: kcOnPrimary(context)),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              color: kcWhite,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (i) {
                  final selected = viewModel.selectedTabIndex == i;
                  final color = selected ? kcPrimary(context) : kcGrey;
                  final labelStyle = kfBodySmall(context,
                      color: selected ? kcPrimary(context) : kcGrey);
                  IconData iconData;
                  String label;
                  switch (i) {
                    case 0:
                      iconData = kiChat;
                      label = 'Chat';
                      break;
                    case 1:
                      iconData = kiCall;
                      label = 'Call';
                      break;
                    case 2:
                      iconData = kiCamera;
                      label = 'Story';
                      break;
                    case 3:
                      iconData = kiContact;
                      label = 'Contact';
                      break;
                    default:
                      iconData = kiAdd;
                      label = 'Profile';
                  }

                  return Expanded(
                    child: InkWell(
                      onTap: () => viewModel.onSelectTab(i),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(iconData, color: color, size: 20),
                          kdSpaceTiny.height,
                          Text(label, style: labelStyle),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          backgroundColor: kcBackground(context).withOpacity(0.95),
          body: CustomScrollView(slivers: [
            AppBarWidget(
              leading: Icon(
                kiMenu,
                color: kcOnPrimary(context),
              ),
              title: "Message",
              automaticallyImplyLeading: false,
              actions: [
                InkWell(
                  onTap: viewModel.onTapSearch,
                  child: Icon(
                    kiSearch,
                    color: kcOnPrimary(context),
                  ),
                ),
                InkWell(
                  onTap: viewModel.onLogout,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: kdPaddingLarge),
                      child: Icon(
                        kiLogout,
                        color: kcOnPrimary(context),
                      )),
                ),
              ],
            ),
            SliverFillRemaining(
              child: StreamBuilder<List<ChatConversation>>(
                stream: viewModel.chatConversationStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(kdSpaceXXLarge),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Failed to load conversations",
                            style: kfBodyLarge(context, fontWeight: FontWeight.bold),
                          ),
                          kdSpaceSmall.height,
                          Text(
                            snapshot.error.toString(),
                            style: kfBodySmall(context, color: kcGrey),
                          ),
                          kdSpaceLarge.height,
                          AppActionButton(
                              onPressed: viewModel.setUp,
                              child: const Text("Retry"))
                        ],
                      ),
                    );
                  }
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
