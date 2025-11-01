import '../../data/models/message_model.dart';

abstract class ChatRepository {
  Stream<List<MessageModel>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, MessageModel message);
}
