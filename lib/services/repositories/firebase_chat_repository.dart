import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:enkoy_chat/enums/chat_message_status.enum.dart';
import 'package:enkoy_chat/interfaces/ichat_repository.dart';
import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/models/ChatMessage.dart';
import 'package:enkoy_chat/models/UserAccount.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class FirebaseChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _realtimeDatabase = FirebaseDatabase.instance;

  final String _chatConversationCollection = "chatConversations";
  final String _chatCollectionPath = "chats";
  final String _usersCollectionPath = "users";
  final String _onlineChatUsersPath = "onlineChatUsers";

  final CloudinaryPublic _cloudinary =
      CloudinaryPublic('dc0pyembs', 'my_unsigned_preset', cache: false);

  @override
  String? get myEmail => _auth.currentUser?.email;

  @override
  String? get myId => _auth.currentUser?.uid;

  @override
  Stream<ChatConversation> fetchSpecificConversationStream(String convId) {
    return _firestore
        .collection(_chatConversationCollection)
        .doc(convId)
        .snapshots()
        .asyncMap((d) async {
      final data = d.data();
      if (data == null) throw StateError('Conversation not found');
      data["id"] = d.id;
      return await _parseConversation(data);
    });
  }

  @override
  Stream<List<ChatConversation>> fetchConversationsStream() {
    final me = myId;
    if (me == null) {
      return Stream.error(StateError('User not authenticated'));
    }
    return _firestore
        .collection(_chatConversationCollection)
        .where("participants", arrayContains: me)
        .snapshots()
        .asyncMap(_chatConversationParser);
  }

  @override
  Stream<List<Chat>> fetchChatsStream(String conversationId) {
    return _firestore
        .collection(_chatConversationCollection)
        .doc(conversationId)
        .collection(_chatCollectionPath)
        .snapshots()
        .asyncMap(_parseChats);
  }

  Future<List<Chat>> _parseChats(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    List<Chat> chats = [];
    for (var doc in snapshot.docs) {
      final chatData = doc.data();
      chatData["id"] = doc.id;
      chats.add(Chat.fromJson(chatData));
    }
    chats.sort((a, b) => b.message.createdAt!.compareTo(a.message.createdAt!));
    return chats;
  }

  Future<List<ChatConversation>> _chatConversationParser(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    List<ChatConversation> conversations = [];
    for (var doc in snapshot.docs) {
      final convData = doc.data();
      convData["id"] = doc.id;
      ChatConversation conversation = await _parseConversation(convData);
      conversations.add(conversation);
    }
    return conversations;
  }

  Future<ChatConversation> _parseConversation(Map<String, dynamic> data) async {
    ChatConversation conversation = ChatConversation.fromJson(data);
    UserAccount? conversee = await _fetchConversee(conversation.participants);
    Chat? lastChat = await _fetchLastMessage(conversation.id);
    conversation = conversation.copyWith(
        conversee: conversee, chats: lastChat != null ? [lastChat] : []);
    return conversation;
  }

  Future<UserAccount?> _fetchConversee(List<String> participants) async {
    final me = myId;
    if (me == null) return null;
    final others = participants.where((p) => p != me);
    if (others.isEmpty) return null;
    final converseeUid = others.first;
    return await _fetchUser(converseeUid);
  }

  Future<Chat?> _fetchLastMessage(String chatConvId) async {
    var snapshot = await _firestore
        .collection(_chatConversationCollection)
        .doc(chatConvId)
        .collection(_chatCollectionPath)
        .orderBy("message.createdAt")
        .limitToLast(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      data["id"] = snapshot.docs.first.id;
      return Chat.fromJson(data);
    }
    return null;
  }

  Future<UserAccount?> _fetchUser(String uid) async {
    var userSnapshot =
        await _firestore.collection(_usersCollectionPath).doc(uid).get();
    if (userSnapshot.exists) {
      final userSnapshotData = userSnapshot.data();
      if (userSnapshotData == null) return null;
      userSnapshotData["uid"] = uid;
      return UserAccount.fromJson(userSnapshotData);
    }
    return null;
  }

  @override
  Future<void> markChatsSeen(
      ChatConversation chatConv, List<Chat> chats) async {
    final meEmail = myEmail;
    final meId = myId;
    if (meEmail == null || meId == null) return;

    final unseenChats = chats
        .where((s) => s.message.status.isSent && s.from != meEmail)
        .toList();

    if (unseenChats.isEmpty) {
      return;
    }

    // Batch writes with a cap to avoid large updates
    final capped = unseenChats.take(50).toList();
    WriteBatch batch = _firestore.batch();
    for (var chat in capped) {
      final docRef = _firestore
          .collection(_chatConversationCollection)
          .doc(chatConv.id)
          .collection(_chatCollectionPath)
          .doc(chat.id);
      batch.update(docRef, {
        "message":
            chat.message.copyWith(status: ChatMessageStatus.seen).toJson(),
      });
    }
    await batch.commit();

    if (chatConv.unseenMessageCount != null &&
        chatConv.unseenMessageCount!.containsKey(meId)) {
      chatConv.unseenMessageCount!.remove(meId);
      await _firestore
          .collection(_chatConversationCollection)
          .doc(chatConv.id)
          .update(chatConv.toJson());
    }
  }

  @override
  Future<void> sendMessage(
      ChatConversation chatConv, ChatMessage message) async {
    final meEmail = myEmail;
    if (meEmail == null) throw StateError('User not authenticated');
    await _firestore
        .collection(_chatConversationCollection)
        .doc(chatConv.id)
        .collection(_chatCollectionPath)
        .add({"from": meEmail, "message": message.toJson()});

    await updateConversationMeta(chatConv);
  }

  @override
  Future<void> updateConversationMeta(ChatConversation chatConv) async {
    final converseeUid = chatConv.conversee?.uid;
    if (converseeUid == null) return;
    int prevUnseenCount = 0;
    if (chatConv.unseenMessageCount != null &&
        chatConv.unseenMessageCount!.containsKey(converseeUid)) {
      prevUnseenCount = chatConv.unseenMessageCount![converseeUid] ?? 0;
    }
    final updated = chatConv.copyWith(unseenMessageCount: {
      ...?chatConv.unseenMessageCount,
      converseeUid: prevUnseenCount + 1,
    });
    await _firestore
        .collection(_chatConversationCollection)
        .doc(chatConv.id)
        .update(updated.toJson());
  }

  @override
  Future<void> activeOnlineStatus(String withConversee,
      {bool withIsTyping = false}) async {
    final meId = myId;
    if (meId == null) return;
    withConversee = withConversee.replaceAll(".", "");
    var activeUserRef = _realtimeDatabase.ref("$_onlineChatUsersPath/$meId");
    await activeUserRef.set({"with": withConversee, "isTyping": withIsTyping});
    activeUserRef.onDisconnect().remove();
  }

  @override
  Future<void> deactiveOnlineStatus() async {
    final meId = myId;
    if (meId == null) return;
    await _realtimeDatabase.ref("$_onlineChatUsersPath/$meId").remove();
  }

  @override
  Future<void> updateTypingStatus({bool isTyping = true}) async {
    final meId = myId;
    if (meId == null) return;
    var activeUserRef = _realtimeDatabase.ref("$_onlineChatUsersPath/$meId");
    await activeUserRef.update({"isTyping": isTyping});
    activeUserRef.onDisconnect().remove();
  }

  @override
  Stream<Map<String, dynamic>?> fetchConverseeOnlineStatus(
      String converseeUid) {
    final meId = myId;
    if (meId == null) {
      return Stream.value(null);
    }
    return _realtimeDatabase
        .ref("$_onlineChatUsersPath/$converseeUid")
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data is Map) {
        return {
          "isActive": true,
          "isTyping": data["with"] == meId && data["isTyping"] == true,
        };
      }
      return null;
    });
  }

  @override
  Future<ChatConversation> getOrInitateChatConversationWith(String to) async {
    var query = await _firestore
        .collection(_chatConversationCollection)
        .where('participants', arrayContains: to)
        .get();

    final conversee = await _fetchUser(to);
    if (conversee == null) {
      throw StateError('Conversee not found');
    }
    final me = myId;
    if (me == null) throw StateError('User not authenticated');

    for (var doc in query.docs) {
      final data = doc.data();
      final participants = List<String>.from(data["participants"]);
      if (participants.contains(me)) {
        data["id"] = doc.id;
        return ChatConversation.fromJson(data).copyWith(conversee: conversee);
      }
    }
    ChatConversation conversation = ChatConversation(
      id: "",
      conversee: conversee,
      participants: [conversee.uid!, me],
    );
    return await _initateChatConversation(conversation);
  }

  Future<ChatConversation> _initateChatConversation(
      ChatConversation conversation) async {
    var ref = _firestore.collection(_chatConversationCollection).doc();
    conversation = conversation.copyWith(id: ref.id);
    await ref.set(conversation.toJson());
    return conversation;
  }

  @override
  Future<List<UserAccount>> searchUsersByEmail(String? email) async {
    final lowerPrefix = email?.toLowerCase() ?? "";
    final upperPrefix = '$lowerPrefix\uf8ff';
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_usersCollectionPath)
          .where('email', isGreaterThanOrEqualTo: lowerPrefix)
          .where('email', isLessThanOrEqualTo: upperPrefix)
          .get();
      List<UserAccount> results = [];

      for (var doc in querySnapshot.docs) {
        if (doc.id == myId) {
          continue;
        }
        final data = doc.data() as Map<String, dynamic>;
        data["uid"] = doc.id;
        results.add(UserAccount.fromJson(data));
      }
      return results;
    } catch (e) {
      debugPrint('searchUsersByEmail error: $e');
      return [];
    }
  }

  @override
  Future<void> syncUserLastUpdatedAt() async {
    final me = myId;
    if (me == null) return;
    await _firestore
        .collection(_usersCollectionPath)
        .doc(me)
        .update({"lastUpdatedAt": FieldValue.serverTimestamp()});
  }

  @override
  Future<String?> uploadImage(XFile? imageFile) async {
    try {
      if (imageFile == null) return null;
      final response = await _cloudinary.uploadFile(CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image));
      return response.secureUrl;
    } catch (e) {
      debugPrint('uploadImage error: $e');
      return null;
    }
  }
}
