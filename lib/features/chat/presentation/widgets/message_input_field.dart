import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_app/core/config/app_constants.dart';
import '../bloc/chat_bloc.dart';
import '../../data/models/message_model.dart';
import 'package:uuid/uuid.dart';

class MessageInputField extends StatefulWidget {
  final String chatId;
  final String receiverId;

  const MessageInputField({
    super.key,
    required this.chatId,
    required this.receiverId,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _typingTimer;
  bool _isTyping = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        _hasText = controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _stopTyping();
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTyping() {
    if (!_isTyping) {
      _isTyping = true;
      context.read<ChatBloc>().add(StartTypingEvent(widget.chatId));
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _stopTyping();
    });
  }

  void _stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      context.read<ChatBloc>().add(StopTypingEvent(widget.chatId));
    }
  }

  void sendMessage() {
    if (controller.text.trim().isEmpty) return;
    _stopTyping();

    final message = MessageModel(
      id: const Uuid().v4(),
      senderId: AppConstants.currentUserId,
      receiverId: widget.receiverId,
      content: controller.text.trim(),
      timestamp: DateTime.now(),
    );

    context.read<ChatBloc>().add(SendMessageEvent(widget.chatId, message));
    controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button (optional)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.add, color: Colors.grey.shade700),
                  onPressed: () {
                    // TODO: Show attachment options
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Text input
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                    onChanged: (_) => _startTyping(),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              Container(
                decoration: BoxDecoration(
                  gradient: _hasText
                      ? LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade400],
                        )
                      : null,
                  color: _hasText ? null : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _hasText ? sendMessage : null,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: Icon(
                        _hasText ? Icons.send : Icons.mic,
                        color: _hasText ? Colors.white : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
