class ChatEntity {
  final String id;
  final List<String> members;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final int unreadCount;

  ChatEntity({
    required this.id,
    required this.members,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCount = 0,
  });
}


