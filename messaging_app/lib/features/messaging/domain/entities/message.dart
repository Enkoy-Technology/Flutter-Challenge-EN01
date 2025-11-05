enum MessageType { text, image, file }
enum MessageStatus { sent, delivered, read }

class Message {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final MessageType type;
  final String? mediaUrl;
  final MessageStatus status;
  final List<String> readBy;

  const Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.type = MessageType.text,
    this.mediaUrl,
    this.status = MessageStatus.sent,
    this.readBy = const [],
  });
}