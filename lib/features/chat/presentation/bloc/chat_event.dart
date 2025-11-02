part of 'chat_bloc.dart';

abstract class ChatEvent {}

class LoadMessagesEvent extends ChatEvent {
  final String chatId;
  LoadMessagesEvent(this.chatId);
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final MessageModel message;
  SendMessageEvent(this.chatId, this.message);
}

class StartTypingEvent extends ChatEvent {
  final String chatId;
  StartTypingEvent(this.chatId);
}

class StopTypingEvent extends ChatEvent {
  final String chatId;
  StopTypingEvent(this.chatId);
}

class MarkMessagesAsReadEvent extends ChatEvent {
  final String chatId;
  MarkMessagesAsReadEvent(this.chatId);
}
