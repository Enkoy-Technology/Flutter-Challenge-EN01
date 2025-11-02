import '../repositories/chat_repository.dart';

class MarkAsReadUsecase {
  final ChatRepository repository;

  MarkAsReadUsecase(this.repository);

  Future<void> call(String messageId, String userId) async {
    return await repository.markMessageAsRead(messageId, userId);
  }
}
