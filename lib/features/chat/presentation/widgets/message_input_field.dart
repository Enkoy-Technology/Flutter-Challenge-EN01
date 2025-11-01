import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injector.dart';
import '../bloc/chat_bloc.dart';
import '../../data/models/message_model.dart';
import 'package:uuid/uuid.dart';

class MessageInputField extends StatefulWidget {
  final String chatId;
  const MessageInputField({super.key, required this.chatId});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final controller = TextEditingController();

  void sendMessage() {
    if (controller.text.trim().isEmpty) return;

    final message = MessageModel(
      id: const Uuid().v4(),
      senderId: 'currentUser', // replace with actual user id
      receiverId: widget.chatId,
      content: controller.text.trim(),
      timestamp: DateTime.now(),
    );

    context.read<ChatBloc>().add(SendMessageEvent(widget.chatId, message));
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.send), onPressed: sendMessage),
          ],
        ),
      ),
    );
  }
}
