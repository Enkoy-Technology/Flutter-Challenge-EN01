import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../utils/time_utils.dart';
import '../theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final dt = TimeUtils.formatMessageTime(message.timestamp);
    if (isMe) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 35),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12, left: 24, right: 0),
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
              decoration: const BoxDecoration(
                color: AppColors.deepPurple,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(17),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(17),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(color: AppColors.white, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dt.toLowerCase(),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.lightPinkText),
                      ),
                      const SizedBox(width: 6),
                      if (message.status == 'seen')
                        const Icon(Icons.done_all,
                            size: 17, color: AppColors.lightBlueAccent)
                      else if (message.status == 'delivered')
                        const Icon(Icons.done_all,
                            size: 17, color: AppColors.whiteText70)
                      else
                        const Icon(Icons.done,
                            size: 17, color: AppColors.whiteText70),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6, left: 0, bottom: 9),
            child: CircleAvatar(
              radius: 17.5,
              backgroundColor: AppColors.primaryGradientStart,
              child: Text(
                (message.sender.isNotEmpty
                    ? message.sender[0].toUpperCase()
                    : '?'),
                style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12, right: 24),
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(17),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(17),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 2.5,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                
                  Text(
                    message.text,
                    style: const TextStyle(color: AppColors.black87, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dt.toLowerCase(),
                    style: const TextStyle(fontSize: 11, color: AppColors.greyText),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}
