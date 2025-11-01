import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'data/repositories/chat_repository.dart';
import 'data/models/chat_model.dart';
import 'data/models/message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatsProvider = StreamProvider<List<ChatModel>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value([]);
  }
  return repository.getChats(user.uid);
});

final messagesProvider = StreamProvider.family<List<MessageModel>, String>(
  (ref, chatId) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.getMessages(chatId);
  },
);

final typingIndicatorProvider =
    StreamProvider.family<bool, TypingIndicatorParams>(
  (ref, params) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.getTypingIndicator(
      params.chatId,
      params.currentUserId,
      params.otherUserId,
    );
  },
);

class TypingIndicatorParams {
  final String chatId;
  final String currentUserId;
  final String otherUserId;

  TypingIndicatorParams({
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
  });
}


