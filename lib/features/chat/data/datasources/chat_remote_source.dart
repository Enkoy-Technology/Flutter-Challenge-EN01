import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> setTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .doc(userId)
        .set({'isTyping': isTyping, 'timestamp': FieldValue.serverTimestamp()});
  }

  Stream<Map<String, bool>> getTypingStatus(
    String chatId,
    String currentUserId,
  ) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('typing')
        .snapshots()
        .map((snapshot) {
          final typingStatus = <String, bool>{};
          for (var doc in snapshot.docs) {
            if (doc.id != currentUserId) {
              final data = doc.data();
              typingStatus[doc.id] = data['isTyping'] ?? false;
            }
          }
          return typingStatus;
        });
  }

  Stream<List<ChatUser>> getAllUsersWithRealtimeLastMessage(
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

      final userMap = <String, ChatUser>{for (var u in users) u.id: u};

      final userStreams = users.map((user) {
        final chatId = _generateChatId(currentUserId, user.id);

        // Listen for last message and unread count together
        final lastMessageStream = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots();

        final unreadStream = _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('receiverId', isEqualTo: currentUserId)
            .where('isRead', isEqualTo: false)
            .snapshots();

        return Rx.combineLatest2(lastMessageStream, unreadStream, (
          QuerySnapshot lastMsgSnap,
          QuerySnapshot unreadSnap,
        ) {
          final updatedUser = userMap[user.id]!;

          if (lastMsgSnap.docs.isNotEmpty) {
            final lastMessageData =
                lastMsgSnap.docs.first.data() as Map<String, dynamic>;
            final lastMessage = MessageModel.fromMap(lastMessageData);
            return updatedUser.copyWith(
              lastMessage: lastMessage.content,
              lastMessageTime: lastMessage.timestamp,
              chatId: chatId,
              unreadCount: unreadSnap.docs.length,
            );
          }

          return updatedUser.copyWith(
            chatId: chatId,
            unreadCount: unreadSnap.docs.length,
          );
        });
      });

      return _combineStreams(userStreams.toList());
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
