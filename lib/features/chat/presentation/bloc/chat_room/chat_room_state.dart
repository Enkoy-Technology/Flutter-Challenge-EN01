import 'package:equatable/equatable.dart';
import '../../../data/models/message_model.dart';

abstract class ChatRoomState extends Equatable {
  const ChatRoomState();

  @override
  List<Object?> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomLoaded extends ChatRoomState {
  final List<MessageModel> messages;

  const ChatRoomLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatRoomError extends ChatRoomState {
  final String message;

  const ChatRoomError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatRoomEmpty extends ChatRoomState {}

class ChatRoomSendingMessage extends ChatRoomState {
  final List<MessageModel> messages;

  const ChatRoomSendingMessage(this.messages);

  @override
  List<Object?> get props => [messages];
}

