import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_app/features/auth/data/models/user_model.dart';
import 'package:flutter_chat_app/features/chat/data/models/chat_user.dart';
import '../models/message_model.dart';
import 'package:rxdart/rxdart.dart';

class ChatRemoteSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());
  }

  Stream<List<ChatUser>>
  getAllUsersWithRealtimeLastMessageWithRealtimeLastMessage(
    String currentUserId,
  ) {
    return _firestore.collection('users').snapshots().switchMap((snapshot) {
      final users = snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => ChatUser.fromMap(doc.data(), doc.id))
          .toList();

      if (users.isEmpty) {
        return Stream.value([]);
      }

      // Create a map to track user updates
      final userMap = <String, ChatUser>{};
      for (final user in users) {
        userMap[user.id] = user;
      }

      // Create a stream for each user's last message
      final messageStreams = users.map((user) {
        final chatId = _generateChatId(currentUserId, user.id);
        return _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots()
            .map((snapshot) {
              final updatedUser = userMap[user.id]!;
              if (snapshot.docs.isNotEmpty) {
                final lastMessageData = snapshot.docs.first.data();
                final lastMessage = MessageModel.fromMap(lastMessageData);
                return updatedUser.copyWith(
                  lastMessage: lastMessage.content,
                  lastMessageTime: lastMessage.timestamp,
                  chatId: chatId,
                );
              }
              return updatedUser.copyWith(chatId: chatId);
            });
      });

      // Combine streams manually
      return _combineStreams(messageStreams.toList());
    });
  }

  Stream<List<ChatUser>> _combineStreams(List<Stream<ChatUser>> streams) {
    if (streams.isEmpty) return Stream.value([]);

    final latestValues = List<ChatUser?>.filled(streams.length, null);
    final completed = List<bool>.filled(streams.length, false);
    var completedCount = 0;

    return Stream.multi((controller) {
      for (var i = 0; i < streams.length; i++) {
        streams[i].listen(
          (user) {
            latestValues[i] = user;
            // Only emit if we have at least one value from each stream
            if (!latestValues.any((value) => value == null)) {
              final users = List<ChatUser>.from(latestValues);
              users.sort((a, b) {
                final timeA = a.lastMessageTime ?? DateTime(0);
                final timeB = b.lastMessageTime ?? DateTime(0);
                return timeB.compareTo(timeA);
              });
              controller.add(users);
            }
          },
          onError: controller.addError,
          onDone: () {
            completed[i] = true;
            completedCount++;
            if (completedCount == streams.length) {
              controller.close();
            }
          },
        );
      }
    });
  }

  String _generateChatId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
}
