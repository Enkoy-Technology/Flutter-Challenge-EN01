import '../../data/models/message_model.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<List<MessageModel>> call(String chatId) {
    return repository.getMessages(chatId);
  }
}
