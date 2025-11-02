import 'dart:developer';

import 'package:enkoy_chat/app/app.locator.dart';
import 'package:enkoy_chat/app/app.router.dart';
import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/models/UserAccount.dart';
import 'package:enkoy_chat/services/chat_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class SearchUserViewModel extends BaseViewModel {
  List<UserAccount> searchResults = [];
  final _chatService = locator<ChatService>();

  final _navigationService = locator<NavigationService>();

  void onSearchValChanged(String? p1) {
    if (busy(searchResults)) {
      log("already searching...");
      return;
    }
    _searchUsersByEmail(p1);
  }

  _searchUsersByEmail(String? p1) async {
    try {
      setBusyForObject(searchResults, true);
      var res = await _chatService.searchUsersByEmail(p1);
      searchResults = res;
    } catch (e) {
      setError(e);
    } finally {
      setBusyForObject(searchResults, false);
    }
  }

  String maskEmail(String email) {
    int atIndex = email.indexOf('@');
    if (atIndex == -1) return email; // Invalid email

    String localPart = email.substring(0, atIndex);
    String domainPart = email.substring(atIndex);

    int visibleChars = (localPart.length / 2).round();
    String maskedLocalPart = localPart.substring(0, visibleChars) +
        '*' * (localPart.length - visibleChars);

    return maskedLocalPart + domainPart;
  }

  void onTapUser(UserAccount searchResult) async {
    setBusy(true);

    final ChatConversation chatConv = await _chatService
        .getOrInitateChatConversationWith(searchResult.uid ?? "");

    await _navigationService.navigateToChatConversationView(
        chatConversation: chatConv);
    setBusy(false);
  }

  void onBack() {
    _navigationService.back();
  }
}
