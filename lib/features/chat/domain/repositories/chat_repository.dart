import '../../data/models/message_model.dart';
import '../../data/models/chat_user.dart';

abstract class ChatRepository {
  Stream<List<MessageModel>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, MessageModel message);
  Future<void> markMessagesAsRead(String chatId, String currentUserId);
  Future<void> markMessagesAsDelivered(String chatId, String currentUserId);
  Future<void> updateMessageStatus(String chatId, String messageId, MessageStatus status);
  Future<void> setTypingStatus(String chatId, String userId, bool isTyping);
  Stream<Map<String, bool>> getTypingStatus(String chatId, String currentUserId);
  Stream<List<ChatUser>> getAllUsersWithRealtimeLastMessage(
    String currentUserId,
  );
}
