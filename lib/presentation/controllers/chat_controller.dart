import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/models/app_user.dart';
import '../../data/repositories/chat_repository.dart';
import '../../domain/models/message.dart';
import 'auth_controller.dart';

class ChatController extends GetxController {
  final ChatRepository _chatRepository = ChatRepository();
  final AuthController _authController = Get.find();
  final Rx<List<Message>> messages = Rx<List<Message>>([]);
  final ScrollController scrollController = ScrollController();
  final RxBool isOtherUserTyping = false.obs;
  Timer? _typingTimer;

  late final String chatId;
  final AppUser otherUser;

  ChatController({required this.otherUser});

  @override
  void onInit() {
    super.onInit();
    final ids = [_authController.currentUser.value!.uid, otherUser.uid];
    ids.sort();
    chatId = ids.join('_');

    // Bind the stream of messages from the repository to our local 'messages' list
    messages.bindStream(_chatRepository.getMessages(chatId));
    _listenToTypingStatus();
    _chatRepository.markMessagesAsSeen(
      chatId,
      _authController.currentUser.value!.uid,
    );

    messages.listen((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _scrollToBottom();
      });
    });
  }

  void _listenToTypingStatus() {
    _chatRepository.getChatStream(chatId).listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('typingStatus')) {
          final typingStatus = data['typingStatus'] as Map<String, dynamic>;
          isOtherUserTyping.value = typingStatus[otherUser.uid] ?? false;
        }
      }
    });
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void onUserTyping() {
    _typingTimer?.cancel();
    _chatRepository.updateUserTypingStatus(
      chatId,
      _authController.currentUser.value!.uid,
      true,
    );
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _chatRepository.updateUserTypingStatus(
        chatId,
        _authController.currentUser.value!.uid,
        false,
      );
    });
  }

  void sendMessage({
    required String senderId,
    required String senderName,
    String? text,
  }) {
    // Use the repository to send the message
    _chatRepository.sendMessage(
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      text: text,
    );
  }

  @override
  void onClose() {
    _typingTimer?.cancel();
    _chatRepository.updateUserTypingStatus(
      chatId,
      _authController.currentUser.value!.uid,
      false,
    );
    scrollController.dispose();
    super.onClose();
  }
}
