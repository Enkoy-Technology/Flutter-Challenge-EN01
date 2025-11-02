
import 'package:flutter/material.dart';

import '../../domain/models/message.dart';
import 'profile_avatar.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          const ProfileAvatar(
              //imageUrl: message.senderProfileImageUrl, // This needs to be added to the Message model
              ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                if (message.type == MessageType.text)
                  Text(
                    message.text,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                if (message.type == MessageType.image && message.mediaUrl != null)
                  Image.network(message.mediaUrl!),
                if (message.type == MessageType.video && message.mediaUrl != null)
                  // Implement video player here
                  Text(
                    'Video: ${message.mediaUrl}',
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
              ],
            ),
          ),
        ),
        if (isMe)
          Icon(
            message.isDelivered ? Icons.done_all : Icons.done,
            color: Colors.grey,
            size: 16,
          ),
      ],
    );
  }
}
