import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import 'chat_service_provider.dart';

final chatProvider =
    StreamProvider.family<List<Message>, String>((ref, chatId) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.subscribeToChatMessages(chatId);
});
