import 'package:equatable/equatable.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class ChatListLoadRequested extends ChatListEvent {}

class ChatListSubscriptionRequested extends ChatListEvent {}

class ChatListUpdated extends ChatListEvent {
  final List<dynamic> chats;

  const ChatListUpdated(this.chats);

  @override
  List<Object?> get props => [chats];
}

class ChatCreateRequested extends ChatListEvent {
  final String otherUserId;

  const ChatCreateRequested(this.otherUserId);

  @override
  List<Object?> get props => [otherUserId];
}

