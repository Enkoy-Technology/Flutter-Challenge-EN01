import 'package:bloc/bloc.dart';
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
    // Load messages in real-time
    on<LoadMessagesEvent>((event, emit) async {
      try {
        await emit.forEach<List<MessageModel>>(
          getMessagesUseCase(event.chatId),
          onData: (messages) => ChatLoaded(messages),
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
        // Optional: you can fetch latest messages or rely on real-time stream
      } catch (e) {
        emit(ChatError("Failed to send message"));
      }
    });
  }
}
