import 'package:equatable/equatable.dart';

abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();

  @override
  List<Object?> get props => [];
}

class ChatRoomMessagesLoadRequested extends ChatRoomEvent {
  final String chatId;

  const ChatRoomMessagesLoadRequested(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class ChatRoomMessagesSubscriptionRequested extends ChatRoomEvent {
  final String chatId;

  const ChatRoomMessagesSubscriptionRequested(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

class ChatRoomMessagesUpdated extends ChatRoomEvent {
  final List<dynamic> messages;

  const ChatRoomMessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatRoomMessageSendRequested extends ChatRoomEvent {
  final String chatId;
  final String content;

  const ChatRoomMessageSendRequested({
    required this.chatId,
    required this.content,
  });

  @override
  List<Object?> get props => [chatId, content];
}

class ChatRoomMediaMessageSendRequested extends ChatRoomEvent {
  final String chatId;
  final String filePath;
  final String messageType;

  const ChatRoomMediaMessageSendRequested({
    required this.chatId,
    required this.filePath,
    required this.messageType,
  });

  @override
  List<Object?> get props => [chatId, filePath, messageType];
}

class ChatRoomMarkMessagesAsRead extends ChatRoomEvent {
  final String chatId;

  const ChatRoomMarkMessagesAsRead(this.chatId);

  @override
  List<Object?> get props => [chatId];
}

