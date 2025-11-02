import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/core/config/app_constants.dart';
import '../../../../core/di/injector.dart';
import '../bloc/chat_bloc.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_field.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverName;
  final String receiverId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.receiverName,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatBloc>()..add(LoadMessagesEvent(widget.chatId)),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.receiverName)),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ChatLoaded) {
                    final messages = state.messages;
                    final typingUsers = state.typingUsers;
                    final isReceiverTyping =
                        typingUsers[widget.receiverId] == true;

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            reverse: true, // This will show latest at bottom
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe =
                                  message.senderId ==
                                  AppConstants.currentUserId;
                              return MessageBubble(
                                message: message,
                                isMe: isMe,
                              );
                            },
                          ),
                        ),
                        if (isReceiverTyping)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TypingIndicator(
                              receiverName: widget.receiverName,
                            ),
                          ),
                      ],
                    );
                  } else if (state is ChatError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
            MessageInputField(
              chatId: widget.chatId,
              receiverId: widget.receiverId,
            ),
          ],
        ),
      ),
    );
  }
}
