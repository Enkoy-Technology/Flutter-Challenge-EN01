import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../data/models/message_model.dart';
import '../../data/models/chat_model.dart';
import '../../domain/entities/message.dart';

final currentUserIdProvider = StateProvider<String>((ref) => 'user1');
final currentUserNameProvider = StateProvider<String>((ref) => 'You');
final currentChatIdProvider = StateProvider<String?>((ref) => null);

final messagesProvider = StreamProvider<List<MessageModel>>((ref) {
  final messagingService = ref.watch(messagingServiceProvider);
  final chatId = ref.watch(currentChatIdProvider);
  return messagingService.getMessages(chatId);
});

final chatsProvider = StreamProvider<List<ChatModel>>((ref) {
  final messagingService = ref.watch(messagingServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return messagingService.getChats(userId);
});

final sendMessageProvider = Provider((ref) {
  final messagingService = ref.watch(messagingServiceProvider);
  return ({
    required String text,
    required String senderId,
    required String senderName,
    String? chatId,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) => messagingService.sendMessage(
    text: text,
    senderId: senderId,
    senderName: senderName,
    chatId: chatId,
    type: type,
    mediaUrl: mediaUrl,
  );
});