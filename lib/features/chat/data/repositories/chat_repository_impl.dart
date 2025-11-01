import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_source.dart';
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
}
