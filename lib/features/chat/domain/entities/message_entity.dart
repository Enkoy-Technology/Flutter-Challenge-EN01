class MessageEntity {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final String type; // 'text' or 'image'
  final String? mediaUrl;
  final DateTime timestamp;
  final bool isRead;

  MessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    this.type = 'text',
    this.mediaUrl,
    required this.timestamp,
    this.isRead = false,
  });
}


