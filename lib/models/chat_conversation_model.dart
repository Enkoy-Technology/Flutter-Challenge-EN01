class ChatConversation {
  final String id;
  final String chatId;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? profileImageUrl;
  final int unreadCount;

  ChatConversation({
    required this.id,
    required this.chatId,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    this.profileImageUrl,
    this.unreadCount = 0,
  });
}

