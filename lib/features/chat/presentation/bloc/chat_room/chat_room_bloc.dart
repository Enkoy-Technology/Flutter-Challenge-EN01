import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repositories/message_repository.dart';
import 'chat_room_event.dart';
import 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final MessageRepository _messageRepository;
  final String _userId;
  StreamSubscription? _messageSubscription;

  ChatRoomBloc(this._messageRepository, this._userId)
    : super(ChatRoomInitial()) {
    on<ChatRoomMessagesLoadRequested>(_onMessagesLoadRequested);
    on<ChatRoomMessagesSubscriptionRequested>(_onMessagesSubscriptionRequested);
    on<ChatRoomMessagesUpdated>(_onMessagesUpdated);
    on<ChatRoomMessageSendRequested>(_onMessageSendRequested);
    on<ChatRoomMediaMessageSendRequested>(_onMediaMessageSendRequested);
    on<ChatRoomMarkMessagesAsRead>(_onMarkMessagesAsRead);
  }

  Future<void> _onMessagesLoadRequested(
    ChatRoomMessagesLoadRequested event,
    Emitter<ChatRoomState> emit,
  ) async {
    emit(ChatRoomLoading());
    try {
      final messages = await _messageRepository.getMessages(event.chatId);
      if (messages.isEmpty) {
        emit(ChatRoomEmpty());
      } else {
        emit(ChatRoomLoaded(messages));
      }
    } catch (e) {
      emit(ChatRoomError(e.toString()));
    }
  }

  Future<void> _onMessagesSubscriptionRequested(
    ChatRoomMessagesSubscriptionRequested event,
    Emitter<ChatRoomState> emit,
  ) async {
    await _messageSubscription?.cancel();

    try {
      _messageSubscription = _messageRepository
          .watchMessages(event.chatId)
          .listen(
            (messages) {
              add(ChatRoomMessagesUpdated(messages));
            },
            onError: (error) {
              emit(ChatRoomError(error.toString()));
            },
          );
    } catch (e) {
      emit(ChatRoomError(e.toString()));
    }
  }

  Future<void> _onMessagesUpdated(
    ChatRoomMessagesUpdated event,
    Emitter<ChatRoomState> emit,
  ) async {
    if (event.messages.isEmpty) {
      emit(ChatRoomEmpty());
    } else {
      emit(ChatRoomLoaded(event.messages.cast()));
    }
  }

  Future<void> _onMessageSendRequested(
    ChatRoomMessageSendRequested event,
    Emitter<ChatRoomState> emit,
  ) async {
    // Create a pending message with microsecond precision
    final now = DateTime.now().toUtc();
    final pendingMessage = MessageModel(
      id: 'pending_${now.microsecondsSinceEpoch}',
      chatId: event.chatId,
      senderId: _userId,
      content: event.content,
      messageType: 'text',
      createdAt: now,
      status: 'pending',
      isRead: false,
    );

    // Add pending message to current state
    if (state is ChatRoomLoaded) {
      final currentMessages = (state as ChatRoomLoaded).messages;
      emit(ChatRoomLoaded([...currentMessages, pendingMessage]));
    }

    try {
      await _messageRepository.sendMessage(
        chatId: event.chatId,
        senderId: _userId,
        content: event.content,
      );
      // Message will be updated via stream subscription
    } catch (e) {
      // Remove pending message and show error
      if (state is ChatRoomLoaded) {
        final currentMessages = (state as ChatRoomLoaded).messages;
        final filteredMessages = currentMessages
            .where((m) => m.id != pendingMessage.id)
            .toList();
        emit(ChatRoomLoaded(filteredMessages));
      }
      emit(ChatRoomError(_extractErrorMessage(e.toString())));
    }
  }

  Future<void> _onMediaMessageSendRequested(
    ChatRoomMediaMessageSendRequested event,
    Emitter<ChatRoomState> emit,
  ) async {
    try {
      await _messageRepository.sendMediaMessage(
        chatId: event.chatId,
        senderId: _userId,
        filePath: event.filePath,
        messageType: event.messageType,
      );
    } catch (e) {
      emit(ChatRoomError(_extractErrorMessage(e.toString())));
    }
  }

  String _extractErrorMessage(String error) {
    // Remove "Exception: " prefix if present
    if (error.startsWith('Exception: ')) {
      error = error.substring('Exception: '.length);
    }
    return error;
  }

  Future<void> _onMarkMessagesAsRead(
    ChatRoomMarkMessagesAsRead event,
    Emitter<ChatRoomState> emit,
  ) async {
    try {
      await _messageRepository.markChatMessagesAsRead(event.chatId, _userId);
    } catch (e) {
      // Silently fail - not critical
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
