import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageUsecase {
  final ChatRepository repository;

  SendMessageUsecase(this.repository);

  Future<void> call(MessageEntity message) async {
    return await repository.sendMessage(message);
  }
}
