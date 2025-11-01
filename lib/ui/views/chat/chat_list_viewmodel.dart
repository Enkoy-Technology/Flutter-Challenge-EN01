import 'package:enkoy_chat/app/app.locator.dart';
import 'package:enkoy_chat/app/app.router.dart';
import 'package:enkoy_chat/interfaces/iauth.interface.dart';
import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/services/chat_service.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ChatListViewModel extends BaseViewModel {
  final _dilogService = locator<DialogService>();
  final _authService = locator<IAuthService>();
  final _chatService = locator<ChatService>();
  final _navigationService = locator<NavigationService>();

  get myId => _chatService.myId;

  setUp() {
    _fetchChatConversations();
  }

  chatConversationStream() {
    return _chatService.fetchConversationsStream();
  }

  Stream<Map<String, dynamic>?> getConverseeOnlineStatus(
      ChatConversation conv) {
    return _chatService.fetchConverseeOnlineStatus(conv.conversee!.uid!);
  }

  _fetchChatConversations() {}

  void onLogout() async {
    var res = await _dilogService.showConfirmationDialog(
      title: "Are you sure you want to log out?",
      confirmationTitle: "Yes",
      barrierDismissible: false,
    );
    if (res?.confirmed ?? false) {
      _authService.logOut();
    }
  }

  void onTapConversation(ChatConversation conversation) {
    _navigationService.navigateToChatConversationView(
        chatConversation: conversation);
  }

  void onTapSearch() {
    _navigationService.navigateToSearchUserView();
  }

  void onPopScope(bool didPop) async {
    var res = await _dilogService.showConfirmationDialog(
      title: "You're going to close the app?",
      confirmationTitle: "Yes",
      barrierDismissible: false,
    );
    if (res?.confirmed ?? false) {
      SystemNavigator.pop();
    }
  }
}
