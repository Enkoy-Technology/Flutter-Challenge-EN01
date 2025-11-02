part of 'chat_bloc.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final Map<String, bool> typingUsers;
  ChatLoaded(this.messages, [this.typingUsers = const {}]);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}
