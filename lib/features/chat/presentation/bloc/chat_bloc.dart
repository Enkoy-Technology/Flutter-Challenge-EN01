import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../data/models/message_model.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/repositories/chat_repository.dart';
import 'package:flutter_chat_app/core/config/app_constants.dart';
part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final ChatRepository repository;
  Map<String, bool> _currentTypingUsers = {};
  StreamSubscription<Map<String, bool>>? _typingSubscription;

  ChatBloc({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.repository,
  }) : super(ChatInitial()) {
    // Load messages in real-time
    on<LoadMessagesEvent>((event, emit) async {
      try {
        // First mark messages as delivered when chat is opened
        await repository.markMessagesAsDelivered(
          event.chatId,
          AppConstants.currentUserId,
        );
        
        // Then mark messages as read
        await repository.markMessagesAsRead(
          event.chatId,
          AppConstants.currentUserId,
        );
        
        // Cancel previous typing subscription if any
        await _typingSubscription?.cancel();
        
        // Start listening to typing status in background
        _typingSubscription = repository.getTypingStatus(event.chatId, AppConstants.currentUserId)
            .listen(
          (typingUsers) {
            _currentTypingUsers = typingUsers;
            if (state is ChatLoaded) {
              emit(ChatLoaded(
                (state as ChatLoaded).messages,
                typingUsers,
              ));
            }
          },
        );
        
        await emit.forEach<List<MessageModel>>(
          getMessagesUseCase(event.chatId),
          onData: (messages) {
            // Mark new unread messages as delivered first, then as read
            final unreadMessages = messages.where((msg) =>
              msg.receiverId == AppConstants.currentUserId &&
              !msg.isRead
            ).toList();
            
            if (unreadMessages.isNotEmpty) {
              // Mark messages as delivered first
              repository.markMessagesAsDelivered(
                event.chatId,
                AppConstants.currentUserId,
              ).then((_) {
                // Then mark as read
                repository.markMessagesAsRead(
                  event.chatId,
                  AppConstants.currentUserId,
                ).catchError((_) {});
              }).catchError((_) {});
            }
            
            return ChatLoaded(
              messages,
              _currentTypingUsers,
            );
          },
          onError: (_, __) => ChatError('Failed to load messages'),
        );
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    // Send message and immediately reflect
    on<SendMessageEvent>((event, emit) async {
      try {
        await sendMessageUseCase(event.chatId, event.message);
        // Stop typing after sending
        await repository.setTypingStatus(
          event.chatId,
          AppConstants.currentUserId,
          false,
        );
      } catch (e) {
        emit(ChatError("Failed to send message"));
      }
    });

    // Handle typing events
    on<StartTypingEvent>((event, emit) async {
      try {
        await repository.setTypingStatus(
          event.chatId,
          AppConstants.currentUserId,
          true,
        );
      } catch (e) {
        // Silently fail for typing
      }
    });

    on<StopTypingEvent>((event, emit) async {
      try {
        await repository.setTypingStatus(
          event.chatId,
          AppConstants.currentUserId,
          false,
        );
      } catch (e) {
        // Silently fail for typing
      }
    });

    on<MarkMessagesAsReadEvent>((event, emit) async {
      try {
        await repository.markMessagesAsRead(
          event.chatId,
          AppConstants.currentUserId,
        );
      } catch (e) {
        // Silently fail
      }
    });
  }

  @override
  Future<void> close() {
    _typingSubscription?.cancel();
    return super.close();
  }
}
