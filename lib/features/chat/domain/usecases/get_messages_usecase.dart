import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUsecase {
  final ChatRepository repository;

  GetMessagesUsecase(this.repository);

  Stream<List<MessageEntity>> call(String chatRoomId) {
    return repository.getMessages(chatRoomId);
  }

  
  Future<List<MessageEntity>> getPaginated(
    String chatRoomId, {
    required int limit,
    MessageEntity? lastMessage, 
  }) {
    return repository.getMessagesPaginated(
      chatRoomId,
      limit: limit,
      lastMessage: lastMessage, 
    );
  }
}
