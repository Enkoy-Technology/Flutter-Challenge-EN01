import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/util/constants.dart';
import '../models/message_model.dart';
import '../models/chat_room_model.dart';

abstract class ChatRemoteDataSource {
  Future<void> sendMessage(MessageModel message);
  Stream<List<MessageModel>> getMessages(String chatRoomId, {int limit = 20});
  Future<List<MessageModel>> getMessagesPaginated(
    String chatRoomId, {
    required int limit,
    MessageModel? lastMessage,
  });
  Future<void> markMessageAsRead(String messageId, String userId);
  Future<void> deleteMessage(String messageId);
  Future<void> editMessage(String messageId, String newContent);
  Stream<List<ChatRoomModel>> getChatRooms(String userId);
  Future<String> createOrGetChatRoom(String currentUserId, String otherUserId);
  Future<ChatRoomModel?> getChatRoom(String chatRoomId);
  Future<void> deleteChatRoom(String chatRoomId);
  Future<String> uploadMedia(String filePath, String messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  late CloudinaryService _cloudinaryService;

  ChatRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore {
    
    _cloudinaryService = CloudinaryService(
      cloudName: 'dplwndrdo', 
      uploadPreset: 'chat-app', 
    );
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    await _firestore
        .collection(Constants.chatsCollection)
        .doc(message.chatRoomId)
        .collection(Constants.messagesCollection)
        .doc(message.id)
        .set(message.toJson());

    
    await _firestore
        .collection(Constants.chatsCollection)
        .doc(message.chatRoomId)
        .update({
      'lastMessage': message.content,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageSenderId': message.senderId,
    });
  }

  @override
  Stream<List<MessageModel>> getMessages(String chatRoomId, {int limit = 20}) {
    return _firestore
        .collection(Constants.chatsCollection)
        .doc(chatRoomId)
        .collection(Constants.messagesCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<List<MessageModel>> getMessagesPaginated(
    String chatRoomId, {
    required int limit,
    MessageModel? lastMessage,
  }) async {
    Query query = _firestore
        .collection(Constants.chatsCollection)
        .doc(chatRoomId)
        .collection(Constants.messagesCollection)
        .orderBy('timestamp', descending: true);

    if (lastMessage != null) {
      query = query.startAfter([lastMessage.timestamp]);
    }

    final querySnapshot = await query.limit(limit).get();

    return querySnapshot.docs
        .map((doc) => MessageModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markMessageAsRead(String messageId, String userId) async {
    final querySnapshot = await _firestore
        .collectionGroup(Constants.messagesCollection)
        .where(FieldPath.documentId, isEqualTo: messageId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final chatRoomId = doc.reference.parent.parent!.id;

      await _firestore
          .collection(Constants.chatsCollection)
          .doc(chatRoomId)
          .collection(Constants.messagesCollection)
          .doc(messageId)
          .update({
        'status': 'read',
        'readBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final querySnapshot = await _firestore
        .collectionGroup(Constants.messagesCollection)
        .where(FieldPath.documentId, isEqualTo: messageId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.delete();
      
    }
  }

  @override
  Future<void> editMessage(String messageId, String newContent) async {
    final querySnapshot = await _firestore
        .collectionGroup(Constants.messagesCollection)
        .where(FieldPath.documentId, isEqualTo: messageId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update({'content': newContent});
    }
  }

  @override
  Stream<List<ChatRoomModel>> getChatRooms(String userId) {
    return _firestore
        .collection(Constants.chatsCollection)
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => ChatRoomModel.fromJson(doc.data()))
          .toList();
    });
  }

  @override
  Future<String> createOrGetChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final chatRoomId = _generateChatRoomId(currentUserId, otherUserId);

    final existingRoom =
        await _firestore.collection(Constants.chatsCollection).doc(chatRoomId).get();

    if (existingRoom.exists) {
      return chatRoomId;
    }

    final otherUserDoc = await _firestore
        .collection(Constants.usersCollection)
        .doc(otherUserId)
        .get();

    final otherUserData = otherUserDoc.data();

    final chatRoomModel = ChatRoomModel(
      id: chatRoomId,
      participants: [currentUserId, otherUserId],
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      createdBy: currentUserId,
      createdAt: DateTime.now(),
      otherUserName: otherUserData?['displayName'] ?? 'Unknown',
      otherUserPhotoUrl: otherUserData?['photoUrl'],
      otherUserOnline: otherUserData?['isOnline'] ?? false,
    );

    await _firestore
        .collection(Constants.chatsCollection)
        .doc(chatRoomId)
        .set(chatRoomModel.toJson());

    return chatRoomId;
  }

  @override
  Future<ChatRoomModel?> getChatRoom(String chatRoomId) async {
    final doc =
        await _firestore.collection(Constants.chatsCollection).doc(chatRoomId).get();

    if (!doc.exists) return null;
    return ChatRoomModel.fromJson(doc.data()!);
  }

  @override
  Future<void> deleteChatRoom(String chatRoomId) async {
    await _firestore.collection(Constants.chatsCollection).doc(chatRoomId).delete();
  }

  @override
  Future<String> uploadMedia(String filePath, String messageId) async {
    try {
      return await _cloudinaryService.uploadMedia(filePath, messageId);
    } catch (e) {
      throw Exception('Media upload failed: ${e.toString()}');
    }
  }

  String _generateChatRoomId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join('_');
  }
}
