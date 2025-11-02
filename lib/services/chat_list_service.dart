import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_conversation_model.dart';

class ChatListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _chatsCollection => _firestore.collection('chats');

  Stream<List<ChatConversation>> getChats(String userId) {
    return _chatsCollection
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final chats = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        int unreadCount = 0;
        if (data['unreadCounts'] != null) {
          final unreadCounts = data['unreadCounts'] as Map<String, dynamic>;
          unreadCount = (unreadCounts[userId] as int?) ?? 0;
        } else {
          unreadCount = data['unreadCount'] ?? 0;
        }

        return ChatConversation(
          id: doc.id,
          chatId: doc.id,
          name: data['name'] ?? 'Chat',
          lastMessage: data['lastMessage'] ?? '',
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ??
              DateTime.now(),
          unreadCount: unreadCount,
        );
      }).toList();

      chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return chats;
    });
  }

  Future<void> createChat(String userId1, String userId2, String userName1,
      String userName2) async {
    final chatId = userId1.compareTo(userId2) < 0
        ? '$userId1-$userId2'
        : '$userId2-$userId1';

    final chatRef = _chatsCollection.doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': [userId1, userId2],
        'name': userName2,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCounts': {
          userId1: 0,
          userId2: 0,
        },
      });
    }
  }

  Future<String> getOrCreateChat(String userId1, String userId2,
      String userName1, String userName2) async {
    final chatId = userId1.compareTo(userId2) < 0
        ? '$userId1-$userId2'
        : '$userId2-$userId1';

    final chatRef = _chatsCollection.doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': [userId1, userId2],
        'name': userName2,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCounts': {
          userId1: 0,
          userId2: 0,
        },
      });
    }

    return chatId;
  }

  Future<void> updateChatLastMessage(
      String chatId, String message, String senderId) async {
    await _chatsCollection.doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementUnreadCount(String chatId, String recipientId) async {
    try {
      final chatRef = _chatsCollection.doc(chatId);
      final chatDoc = await chatRef.get();

      if (chatDoc.exists) {
        final data = chatDoc.data() as Map<String, dynamic>;
        final participants = (data['participants'] as List).cast<String>();

        if (participants.contains(recipientId)) {
          final unreadCountsPath = 'unreadCounts.$recipientId';
          await chatRef.update({
            unreadCountsPath: FieldValue.increment(1),
          });
        }
      }
    } catch (e) {
    }
  }

  Future<void> resetUnreadCount(String chatId, String userId) async {
    try {
      await _chatsCollection.doc(chatId).update({
        'unreadCounts.$userId': 0,
      });
    } catch (e) {
    }
  }
}
