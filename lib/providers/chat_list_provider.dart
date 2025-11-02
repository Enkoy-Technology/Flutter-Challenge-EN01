import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_list_service.dart';
import '../models/chat_conversation_model.dart';
import 'auth_provider.dart';

final chatListServiceProvider =
    Provider<ChatListService>((ref) => ChatListService());

final chatListProvider = StreamProvider<List<ChatConversation>>((ref) {
  final chatListService = ref.watch(chatListServiceProvider);
  final authState = ref.watch(authStateProvider);

  if (authState.valueOrNull == null) {
    return Stream.value([]);
  }

  final userId = authState.valueOrNull?.id;
  if (userId == null) {
    return Stream.value([]);
  }

  return chatListService.getChats(userId);
});
