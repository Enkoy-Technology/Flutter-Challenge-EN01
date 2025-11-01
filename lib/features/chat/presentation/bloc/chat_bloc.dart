import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  ChatBloc({required this.getMessagesUseCase, required this.sendMessageUseCase})
    : super(ChatInitial()) {
    on<LoadMessagesEvent>((event, emit) {
      emit(ChatLoading());
      emit.forEach<List<MessageModel>>(
        getMessagesUseCase(event.chatId),
        onData: (messages) => ChatLoaded(messages),
        onError: (_, __) => ChatError("Failed to load messages"),
      );
    });

    on<SendMessageEvent>((event, emit) async {
      try {
        await sendMessageUseCase(event.chatId, event.message);
      } catch (e) {
        emit(ChatError("Failed to send message"));
      }
    });
  }
}
