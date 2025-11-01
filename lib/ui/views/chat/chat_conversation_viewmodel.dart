import 'dart:async';
import 'dart:developer';
import 'package:enkoy_chat/app/app.locator.dart';
import 'package:enkoy_chat/enums/chat_message_type.enum.dart';
import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/models/ChatMessage.dart';
import 'package:enkoy_chat/services/chat_service.dart';
import 'package:enkoy_chat/ui/common/utils/datetime_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';

class ChatConversationViewModel extends BaseViewModel {
  final ChatConversation chatConversationBase;

  ChatConversationViewModel({required this.chatConversationBase});

  final ChatService _chatService = locator<ChatService>();

  TextEditingController chatTextInputController = TextEditingController();

  FocusNode chatTextFieldFocusNode = FocusNode();

  Timer? typingTimerUpdater;
  Timer? onlineStatusDeactivator;
  int maxTypingTresholdSec = 2;
  int maxOnlineWaitSec = 60;

  bool isActiveWithMe = false;
  bool isConverseeTyping = false;

  String get myEmail => _chatService.myEmail;

  ChatConversation? latestConversation;
  List<Chat> loadedChats = [];

  void setUp() {
    _onlineUserStatusUpdater();
    _syncUserLastUpdatedAt();
    _listenToLatestConversation();
  }

  refreshLoadedChats(List<Chat> chats) {
    loadedChats = chats;
  }

  Stream<List<Chat>> getChatStream() {
    return _chatService.fetchChatsStream(chatConversationBase.id);
  }

  List<MapEntry<String, List<Chat>>> getGroupedChats(List<Chat> chats) {
    return chats
        .groupListsBy((s) => DateTimeUtils.formatDate(s.message.createdAt))
        .entries
        .toList();
  }

  Stream<Map<String, dynamic>?> getConverseeOnlineStatus() {
    return _chatService
        .fetchConverseeOnlineStatus(chatConversationBase.conversee!.uid!);
  }

  void onChatTextTyping(String? p1) {
    _onlineUserStatusUpdater(isTyping: true);
    //deactivate typing after sometime later
    _deactivateTyping();
    rebuildUi();
  }

  void onSendChatMessage() {
    ChatMessage chatMessage = ChatMessage(
        text: chatTextInputController.text, contentType: ChatMessageType.text);
    _chatService.sendMessage(
        latestConversation ?? chatConversationBase, chatMessage);

    chatTextInputController.clear();

    //sync lastupdated snapshot
    _syncUserLastUpdatedAt();
  }

  _listenToLatestConversation() {
    _chatService
        .fetchSpecificConversationStream(chatConversationBase.id)
        .listen((chatConv) {
      latestConversation = chatConv;
      _chatService.seenMyUnseenChats(latestConversation!, loadedChats);
      log("latest conv updated.");
    });
  }

  void _syncUserLastUpdatedAt() {
    _chatService.syncUserLastUpdatedAt();
  }

  void _onlineUserStatusUpdater({bool isTyping = false}) {
    _chatService.activeOnlineStatus(chatConversationBase.conversee!.uid!,
        withIsTyping: isTyping);
    _deactivateOnlineStatus();
  }

  void _deactivateOnlineStatus() {
    onlineStatusDeactivator?.cancel();
    onlineStatusDeactivator = Timer(Duration(seconds: maxOnlineWaitSec), () {
      _chatService.deactiveOnlineStatus();
      onlineStatusDeactivator?.cancel();
    });
  }

  void _deactivateTyping() {
    typingTimerUpdater?.cancel();
    typingTimerUpdater = Timer(Duration(seconds: maxTypingTresholdSec), () {
      _chatService.updateTypingStatus(isTyping: false);
      typingTimerUpdater?.cancel();
    });
  }
}
