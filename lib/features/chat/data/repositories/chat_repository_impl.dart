import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_source.dart';
import '../models/chat_user.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteSource remoteSource;

  ChatRepositoryImpl({required this.remoteSource});

  @override
  Stream<List<MessageModel>> getMessages(String chatId) {
    return remoteSource.getMessages(chatId);
  }

  @override
  Future<void> sendMessage(String chatId, MessageModel message) {
    return remoteSource.sendMessage(chatId, message);
  }

  @override
  Stream<List<ChatUser>> getAllUsersWithRealtimeLastMessage(
    String currentUserId,
  ) {
    return remoteSource.getAllUsersWithRealtimeLastMessage(currentUserId);
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String currentUserId) {
    return remoteSource.markMessagesAsRead(chatId, currentUserId);
  }

  @override
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping) {
    return remoteSource.setTypingStatus(chatId, userId, isTyping);
  }

  @override
  Stream<Map<String, bool>> getTypingStatus(String chatId, String currentUserId) {
    return remoteSource.getTypingStatus(chatId, currentUserId);
  }
}
