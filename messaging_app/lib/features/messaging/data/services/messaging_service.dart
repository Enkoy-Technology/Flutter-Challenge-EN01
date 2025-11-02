import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../../domain/entities/message.dart';

class MessagingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _messagesCollection = 'messages';
  final String _chatsCollection = 'chats';
  final String _usersCollection = 'users';

  // Messages query with proper chat filtering
  Stream<List<MessageModel>> getMessages([String? chatId]) {
    return _firestore
        .collection(_messagesCollection)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          var messages = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final message = MessageModel.fromFirestore(doc);
            // Add chatId from document data for filtering
            return MessageModel(
              id: message.id,
              text: message.text,
              senderId: message.senderId,
              senderName: message.senderName,
              timestamp: message.timestamp,
              type: message.type,
              mediaUrl: message.mediaUrl,
              status: message.status,
              readBy: message.readBy,
            );
          }).toList();
          
          // Filter by chatId if specified
          if (chatId != null) {
            messages = messages.where((message) {
              final docData = snapshot.docs
                  .firstWhere((doc) => doc.id == message.id)
                  .data() as Map<String, dynamic>;
              return docData['chatId'] == chatId;
            }).toList();
          }
          
          return messages;
        });
  }

  // Simple chats query without orderBy to avoid index issues
  Stream<List<ChatModel>> getChats(String userId) {
    return _firestore
        .collection(_chatsCollection)
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs
              .map((doc) => ChatModel.fromFirestore(doc))
              .where((chat) => chat.participants.contains(userId))
              .toList();
          // Sort by last message time in memory
          chats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
          return chats;
        });
  }

  Future<void> sendMessage({
    required String text,
    required String senderId,
    required String senderName,
    String? chatId,
    MessageType type = MessageType.text,
    String? mediaUrl,
  }) async {
    final message = MessageModel(
      id: '',
      text: text,
      senderId: senderId,
      senderName: senderName,
      timestamp: DateTime.now(),
      type: type,
      mediaUrl: mediaUrl,
    );

    final messageData = message.toFirestore();
    // Always include chatId in the message data
    if (chatId != null) {
      messageData['chatId'] = chatId;
    }

    await _firestore.collection(_messagesCollection).add(messageData);
    
    // Update chat's last message
    if (chatId != null) {
      await _updateChatLastMessage(chatId, text);
    }
  }

  Future<void> _updateChatLastMessage(String chatId, String message) async {
    await _firestore.collection(_chatsCollection).doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> markMessageAsRead(String messageId, String userId) async {
    await _firestore.collection(_messagesCollection).doc(messageId).update({
      'readBy': FieldValue.arrayUnion([userId]),
      'status': MessageStatus.read.name,
    });
  }

  Future<void> createUser(UserModel user) async {
    await _firestore.collection(_usersCollection).doc(user.id).set(user.toFirestore());
  }

  Future<void> updateUserStatus(String userId, bool isOnline) async {
    await _firestore.collection(_usersCollection).doc(userId).update({
      'isOnline': isOnline,
    });
  }

  Future<String> createChat(String name, List<String> participants) async {
    final chat = ChatModel(
      id: '',
      name: name,
      lastMessage: 'Chat created',
      lastMessageTime: DateTime.now(),
      participants: participants,
    );

    final docRef = await _firestore.collection(_chatsCollection).add(chat.toFirestore());
    return docRef.id;
  }

  // Mock media upload
  Future<String> uploadMedia(File file) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'https://example.com/media/${file.path.split('/').last}';
  }
}