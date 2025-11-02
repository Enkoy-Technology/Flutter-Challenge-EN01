import '../entities/message_entity.dart';
import '../entities/chat_room_entity.dart';

abstract class ChatRepository {
  
  Future<void> sendMessage(MessageEntity message);
  Stream<List<MessageEntity>> getMessages(String chatRoomId, {int limit = 20});
  Future<List<MessageEntity>> getMessagesPaginated(
    String chatRoomId, {
    required int limit,
    MessageEntity? lastMessage,
  });
  Future<void> markMessageAsRead(String messageId, String userId);
  Future<void> deleteMessage(String messageId);
  Future<void> editMessage(String messageId, String newContent);

  
  Stream<List<ChatRoomEntity>> getChatRooms(String userId);
  Future<String> createOrGetChatRoom(String currentUserId, String otherUserId);
  Future<ChatRoomEntity?> getChatRoom(String chatRoomId);
  Future<void> deleteChatRoom(String chatRoomId);

  
  Future<String> uploadMedia(String filePath, String messageId);
  
}
