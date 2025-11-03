import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/chat_repository.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository _chatRepository;
  final String _userId;
  StreamSubscription? _chatSubscription;

  ChatListBloc(this._chatRepository, this._userId) : super(ChatListInitial()) {
    on<ChatListLoadRequested>(_onChatListLoadRequested);
    on<ChatListSubscriptionRequested>(_onChatListSubscriptionRequested);
    on<ChatListUpdated>(_onChatListUpdated);
    on<ChatCreateRequested>(_onChatCreateRequested);
  }

  Future<void> _onChatListLoadRequested(
    ChatListLoadRequested event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());
    try {
      final chats = await _chatRepository.getChats(_userId);
      if (chats.isEmpty) {
        emit(ChatListEmpty());
      } else {
        emit(ChatListLoaded(chats));
      }
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> _onChatListSubscriptionRequested(
    ChatListSubscriptionRequested event,
    Emitter<ChatListState> emit,
  ) async {
    await _chatSubscription?.cancel();
    
    try {
      _chatSubscription = _chatRepository.watchChats(_userId).listen(
        (chats) {
          add(ChatListUpdated(chats));
        },
        onError: (error) {
          emit(ChatListError(error.toString()));
        },
      );
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> _onChatListUpdated(
    ChatListUpdated event,
    Emitter<ChatListState> emit,
  ) async {
    if (event.chats.isEmpty) {
      emit(ChatListEmpty());
    } else {
      emit(ChatListLoaded(event.chats.cast()));
    }
  }

  Future<void> _onChatCreateRequested(
    ChatCreateRequested event,
    Emitter<ChatListState> emit,
  ) async {
    try {
      await _chatRepository.getOrCreateChat(_userId, event.otherUserId);
      add(ChatListLoadRequested());
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }
}

