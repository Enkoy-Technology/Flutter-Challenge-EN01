import '../../data/models/message_model.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call(String chatId, MessageModel message) {
    return repository.sendMessage(chatId, message);
  }
}
