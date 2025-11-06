import 'package:enkoy_chat/app/app.locator.dart';
import 'package:enkoy_chat/interfaces/ichat_repository.dart';
import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/models/ChatMessage.dart';
import 'package:enkoy_chat/models/UserAccount.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// ChatService
///
/// Core service for all chat related use-cases
///
/// Unimplemented features:
/// TODO: Caching
/// TODO: Paginating chat messages
/// TODO: Supporing different type of message content(audio, document)
/// TODO: Audio/video calling
/// TODO: Chat edit, delete
/// TODO: Push notifications
///
/// By: Amanuel.T (AKA: Emant)
///
///
class ChatService {
  final IChatRepository _repo = locator<IChatRepository>();

  String get myEmail => _repo.myEmail ?? '';
  String get myId => _repo.myId ?? '';

  Stream<ChatConversation> fetchSpecificConversationStream(String convId) =>
      _repo.fetchSpecificConversationStream(convId);

  Stream<List<ChatConversation>> fetchConversationsStream() =>
      _repo.fetchConversationsStream();

  Stream<List<Chat>> fetchChatsStream(String conversationId) =>
      _repo.fetchChatsStream(conversationId);

  Future<void> seenMyUnseenChats(
          ChatConversation chatConv, List<Chat> chats) async =>
      _repo.markChatsSeen(chatConv, chats);

  Future<void> sendMessage(
          ChatConversation chatConv, ChatMessage message) async =>
      _repo.sendMessage(chatConv, message);

  Future<ChatConversation> getOrInitateChatConversationWith(String to) =>
      _repo.getOrInitateChatConversationWith(to);

  Stream<Map<String, dynamic>?> fetchConverseeOnlineStatus(
          String converseeUid) =>
      _repo.fetchConverseeOnlineStatus(converseeUid);

  Future<List<UserAccount>> searchUsersByEmail(String? email) async =>
      (await _repo.searchUsersByEmail(email));

  Future<void> syncUserLastUpdatedAt() => _repo.syncUserLastUpdatedAt();

  Future<String?> uploadImage(XFile? imageFile) => _repo.uploadImage(imageFile);

  Future<void> activeOnlineStatus(String withConversee,
          {bool withIsTyping = false}) =>
      _repo.activeOnlineStatus(withConversee, withIsTyping: withIsTyping);

  Future<void> deactiveOnlineStatus() => _repo.deactiveOnlineStatus();

  Future<void> updateTypingStatus({bool isTyping = true}) =>
      _repo.updateTypingStatus(isTyping: isTyping);
}
