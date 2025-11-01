import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/chat_utils.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Get all chats for a user - real-time stream
  Stream<List<ChatModel>> getChats(String userId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .where('members', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots(includeMetadataChanges: false) // Get only document changes
        .map((snapshot) {
          final chats = snapshot.docs
              .map((doc) => ChatModel.fromFirestore(doc))
              .toList();
          // Sort manually to handle null lastMessageTime (new chats appear at bottom)
          chats.sort((a, b) {
            if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
            if (a.lastMessageTime == null) return 1;
            if (b.lastMessageTime == null) return -1;
            return b.lastMessageTime!.compareTo(a.lastMessageTime!);
          });
          return chats;
        });
  }

  // Get messages for a chat - real-time stream
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection(AppConstants.messagesCollection)
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots(includeMetadataChanges: false) // Get only document changes, not metadata
        .map((snapshot) {
          // Convert all documents to MessageModel
          return snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList();
        });
  }

  // Create or get existing chat
  Future<String> createOrGetChat(String userId1, String userId2) async {
    final chatId = ChatUtils.getChatId(userId1, userId2);

    final chatDoc =
        await _firestore.collection(AppConstants.chatsCollection).doc(chatId).get();

    if (!chatDoc.exists) {
      await _firestore.collection(AppConstants.chatsCollection).doc(chatId).set({
        'members': [userId1, userId2],
        'lastMessage': null,
        'lastMessageTime': null,
        'lastMessageSenderId': null,
        'unreadCount': 0,
      });
    }

    return chatId;
  }

  // Send a text message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final messageId = _uuid.v4();
    final message = MessageModel(
      id: messageId,
      chatId: chatId,
      senderId: senderId,
      text: text,
      type: AppConstants.messageTypeText,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Add message to messages subcollection
    await _firestore
        .collection(AppConstants.messagesCollection)
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(message.toFirestore());

    // Update chat document
    await _firestore.collection(AppConstants.chatsCollection).doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': ChatUtils.getCurrentTimestamp(),
      'lastMessageSenderId': senderId,
      // Increment unread count (for the other user who didn't send this)
      'unreadCount': FieldValue.increment(1),
    });
  }

  // Send an image message
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String imagePath,
  }) async {
    try {
      final messageId = _uuid.v4();
      
      // Upload image to Cloudinary - linked to chat ID and message ID
      final file = File(imagePath);
      final imageUrl = await CloudinaryService.uploadChatMedia(
        imageFile: file,
        chatId: chatId,
        messageId: messageId,
      );
      final message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        text: '📷 Image',
        type: AppConstants.messageTypeImage,
        mediaUrl: imageUrl,
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Add message to messages subcollection
      await _firestore
          .collection(AppConstants.messagesCollection)
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set(message.toFirestore());

      // Update chat document
      await _firestore.collection(AppConstants.chatsCollection).doc(chatId).update({
        'lastMessage': '📷 Image',
        'lastMessageTime': ChatUtils.getCurrentTimestamp(),
        'lastMessageSenderId': senderId,
        // Increment unread count (for the other user who didn't send this)
        'unreadCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to send image: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      // Get all messages in the chat (simpler query, no index needed)
      final messagesSnapshot = await _firestore
          .collection(AppConstants.messagesCollection)
          .doc(chatId)
          .collection('messages')
          .get();

      // Filter in memory and update unread messages
      final batch = _firestore.batch();
      int unreadCount = 0;
      
      for (var doc in messagesSnapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String?;
        final isRead = data['isRead'] as bool? ?? false;
        
        // Only update messages from other users that are unread
        if (senderId != null && senderId != userId && !isRead) {
          batch.update(doc.reference, {'isRead': true});
          unreadCount++;
        }
      }
      
      if (unreadCount > 0) {
        await batch.commit();
      }

      // Reset unread count for this chat
      await _firestore
          .collection(AppConstants.chatsCollection)
          .doc(chatId)
          .update({'unreadCount': 0});
    } catch (e) {
      // Silently handle errors - not critical if read receipts fail
      print('Error marking messages as read: $e');
    }
  }

  // Set typing indicator
  Future<void> setTypingIndicator(String chatId, String userId, bool isTyping) async {
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .update({'typing_$userId': isTyping});
  }

  // Get typing indicator - real-time stream
  Stream<bool> getTypingIndicator(String chatId, String userId, String otherUserId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .snapshots(includeMetadataChanges: false) // Get only document changes
        .map((doc) => doc.data()?['typing_$otherUserId'] ?? false);
  }
}

