import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/models/ChatMessage.dart';
import 'package:enkoy_chat/models/UserAccount.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

abstract class IChatRepository {
  String? get myEmail;
  String? get myId;

  Stream<ChatConversation> fetchSpecificConversationStream(String convId);
  Stream<List<ChatConversation>> fetchConversationsStream();
  Stream<List<Chat>> fetchChatsStream(String conversationId);

  Future<ChatConversation> getOrInitateChatConversationWith(String to);
  Future<List<UserAccount>> searchUsersByEmail(String? email);
  Future<String?> uploadImage(XFile? imageFile);

  Future<void> sendMessage(ChatConversation chatConv, ChatMessage message);
  Future<void> markChatsSeen(ChatConversation chatConv, List<Chat> chats);
  Future<void> updateConversationMeta(ChatConversation chatConv);

  Future<void> syncUserLastUpdatedAt();

  // Presence / typing
  Future<void> activeOnlineStatus(String withConversee, {bool withIsTyping});
  Future<void> deactiveOnlineStatus();
  Future<void> updateTypingStatus({bool isTyping});
  Stream<Map<String, dynamic>?> fetchConverseeOnlineStatus(String converseeUid);
}



