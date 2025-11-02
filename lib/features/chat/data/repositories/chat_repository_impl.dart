import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/message_model.dart';
import '../models/chat_room_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> sendMessage(MessageEntity message) async {
    final messageModel = MessageModel.fromEntity(message);
    await remoteDataSource.sendMessage(messageModel);
  }

  @override
  Stream<List<MessageEntity>> getMessages(String chatRoomId, {int limit = 20}) {
    return remoteDataSource.getMessages(chatRoomId, limit: limit).map(
          (messages) => messages.cast<MessageEntity>(),
        );
  }

  @override
  Future<List<MessageEntity>> getMessagesPaginated(
    String chatRoomId, {
    required int limit,
    MessageEntity? lastMessage,
  }) async {
    final lastMessageModel =
        lastMessage != null ? MessageModel.fromEntity(lastMessage) : null;

    final messages = await remoteDataSource.getMessagesPaginated(
      chatRoomId,
      limit: limit,
      lastMessage: lastMessageModel,
    );
    return messages.cast<MessageEntity>();
  }

  @override
  Future<void> markMessageAsRead(String messageId, String userId) async {
    await remoteDataSource.markMessageAsRead(messageId, userId);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await remoteDataSource.deleteMessage(messageId);
  }

  @override
  Future<void> editMessage(String messageId, String newContent) async {
    await remoteDataSource.editMessage(messageId, newContent);
  }

  @override
  Stream<List<ChatRoomEntity>> getChatRooms(String userId) {
    return remoteDataSource.getChatRooms(userId).map(
          (rooms) => rooms.cast<ChatRoomEntity>(),
        );
  }

  @override
  Future<String> createOrGetChatRoom(String currentUserId, String otherUserId) async {
    return await remoteDataSource.createOrGetChatRoom(currentUserId, otherUserId);
  }

  @override
  Future<ChatRoomEntity?> getChatRoom(String chatRoomId) async {
    return await remoteDataSource.getChatRoom(chatRoomId);
  }

  @override
  Future<void> deleteChatRoom(String chatRoomId) async {
    await remoteDataSource.deleteChatRoom(chatRoomId);
  }

  @override
  Future<String> uploadMedia(String filePath, String messageId) async {
    return await remoteDataSource.uploadMedia(filePath, messageId);
  }
}
