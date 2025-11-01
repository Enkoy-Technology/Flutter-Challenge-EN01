import '../../data/models/message_model.dart';
import '../../data/models/chat_user.dart';

abstract class ChatRepository {
  Stream<List<MessageModel>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, MessageModel message);
  Stream<List<ChatUser>> getAllUsers(String currentUserId);
}
