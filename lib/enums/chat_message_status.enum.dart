enum ChatMessageStatus { sent, delivered, seen }

extension ChatMessageStatusX on ChatMessageStatus {
  bool get isSent => ChatMessageStatus.sent == this;
  bool get isDelivered => ChatMessageStatus.delivered == this;
  bool get isSeen => ChatMessageStatus.seen == this;
}
