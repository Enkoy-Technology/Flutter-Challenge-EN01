import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_field.dart';
import '../../data/models/message_model.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatBloc>()..add(LoadMessagesEvent(chatId)),
      child: Scaffold(
        appBar: AppBar(title: Text(receiverName)),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatLoaded) {
                    final messages = state.messages;
                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe =
                            message.senderId ==
                            'currentUser'; // replace with real current user
                        return MessageBubble(message: message, isMe: isMe);
                      },
                    );
                  } else if (state is ChatError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
            MessageInputField(chatId: chatId),
          ],
        ),
      ),
    );
  }
}
