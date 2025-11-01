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
