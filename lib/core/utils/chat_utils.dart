import 'package:cloud_firestore/cloud_firestore.dart';

class ChatUtils {
  static String getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  static String getOtherUserId(String chatId, String currentUserId) {
    final parts = chatId.split('_');
    if (parts.length != 2) return '';
    return parts[0] == currentUserId ? parts[1] : parts[0];
  }

  static Timestamp getCurrentTimestamp() {
    return Timestamp.now();
  }
}


