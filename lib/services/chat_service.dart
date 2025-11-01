import 'package:enkoy_chat/enums/chat_message_status.enum.dart';
import 'package:enkoy_chat/models/Chat.dart';
import 'package:enkoy_chat/models/ChatConversation.dart';
import 'package:enkoy_chat/models/ChatMessage.dart';
import 'package:enkoy_chat/models/UserAccount.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// ChatService
///
/// Core service for all chat related use-cases
///
/// Unimplemented features:
/// TODO: Caching
/// TODO: Paginating chat messages
/// TODO: Supporing different type of message content(audio, picture, document)
/// TODO: Audio/video calling
/// TODO: Chat edit, delete
/// TODO: Push notifications
///
/// By: Amanuel.T (AKA: Emant)
///
///
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _realtimeDatabase = FirebaseDatabase.instance;

  final String _chatConversationCollection = "chatConversations";
  final String _chatCollectionPath = "chats";
  final String _usersCollectionPath = "users";
  final String _onlineChatUsersPath = "onlineChatUsers";

  User get _me => _auth.currentUser!;
  String get myEmail => _me.email!;
  String get myId => _me.uid;

  Stream<ChatConversation> fetchSpecificConversationStream(String convId) {
    return _firestore
        .collection(_chatConversationCollection)
        .doc(convId)
        .snapshots()
        .asyncMap((d) async {
      dynamic data = d.data();
      data["id"] = d.id;
      return await _parseConversation(data);
    });
  }

  Stream<List<ChatConversation>> fetchConversationsStream() {
    return _firestore
        .collection(_chatConversationCollection)
        .where("participants", arrayContains: _me.uid)
        .snapshots()
        .asyncMap(_chatConversationParser);
  }

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
      dynamic chatData = doc.data();
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
      dynamic convData = doc.data();
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

  _fetchConversee(List<String> participants) async {
    //fetch other convesee
    String converseeUid = participants.where((p) => p != _me.uid).first;
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
      dynamic data = snapshot.docs.first.data();
      data["id"] = snapshot.docs.first.id;
      return Chat.fromJson(data);
    }
    return null;
  }

  Future<UserAccount?> _fetchUser(String uid) async {
    var userSnapshot =
        await _firestore.collection(_usersCollectionPath).doc(uid).get();
    if (userSnapshot.exists) {
      dynamic userSnapshotData = userSnapshot.data();
      userSnapshotData["uid"] = uid;
      return UserAccount.fromJson(userSnapshotData);
    }

    return null;
  }

  void seenMyUnseenChats(ChatConversation chatConv, List<Chat> chats) async {
    List<Chat> unseenChats = chats
        .where((s) => s.message.status.isSent && s.from != _me.email)
        .toList();

    for (var chat in unseenChats) {
      FirebaseFirestore.instance
          .collection(_chatConversationCollection)
          .doc(chatConv.id)
          .collection(_chatCollectionPath)
          .doc(chat.id)
          .update({
        "message":
            chat.message.copyWith(status: ChatMessageStatus.seen).toJson()
      });
    }

    if (unseenChats.isNotEmpty &&
        chatConv.unseenMessageCount != null &&
        chatConv.unseenMessageCount!.containsKey(_me.uid)) {
      chatConv.unseenMessageCount!.remove(_me.uid);
      FirebaseFirestore.instance
          .collection(_chatConversationCollection)
          .doc(chatConv.id)
          .update(chatConv.toJson());
    }
  }

  void sendMessage(ChatConversation chatConv, ChatMessage message) {
    FirebaseFirestore.instance
        .collection(_chatConversationCollection)
        .doc(chatConv.id)
        .collection(_chatCollectionPath)
        .add({"from": _me.email, "message": message.toJson()});

    //Update conversation meta: unseen count, and lastupdate
    _updateConversationMeta(chatConv);
  }

  void _updateConversationMeta(ChatConversation chatConv) {
    int prevUnseenCount = 0;
    if (chatConv.unseenMessageCount != null &&
        chatConv.unseenMessageCount!.containsKey(chatConv.conversee!.uid)) {
      prevUnseenCount =
          chatConv.unseenMessageCount![chatConv.conversee!.uid!] ?? 0;
    }
    ChatConversation chatConvUpdated = chatConv.copyWith(unseenMessageCount: {
      ...?chatConv.unseenMessageCount,
      chatConv.conversee!.uid!: prevUnseenCount + 1
    });

    FirebaseFirestore.instance
        .collection(_chatConversationCollection)
        .doc(chatConv.id)
        .update(chatConvUpdated.toJson());
  }

  Future<void> activeOnlineStatus(String withConversee,
      {bool withIsTyping = false}) async {
    withConversee = withConversee.replaceAll(".", "");
    var activeUserRef =
        _realtimeDatabase.ref("$_onlineChatUsersPath/${_me.uid}");
    activeUserRef.set({"with": withConversee, "isTyping": withIsTyping});
    activeUserRef.onDisconnect().remove();
  }

  Future<void> deactiveOnlineStatus() async {
    //deactive online status after sometime of inactivity
    await _realtimeDatabase.ref("$_onlineChatUsersPath/${_me.uid}").remove();
  }

  Future<void> updateTypingStatus({bool isTyping = true}) async {
    var activeUserRef =
        _realtimeDatabase.ref("$_onlineChatUsersPath/${_me.uid}");
    activeUserRef.update({"isTyping": isTyping});
    activeUserRef.onDisconnect().remove();
  }

  Future<ChatConversation> getOrInitateChatConversationWith(String to) async {
    var query = await _firestore
        .collection(_chatConversationCollection)
        .where('participants', arrayContains: to)
        .get();

    UserAccount conversee = (await _fetchUser(to))!;
    for (var doc in query.docs) {
      dynamic data = doc.data();
      List<String> participants = List<String>.from(data["participants"]);
      if (participants.contains(_me.uid)) {
        data["id"] = doc.id;
        return ChatConversation.fromJson(data).copyWith(conversee: conversee);
      }
    }
    ChatConversation conversation = ChatConversation(
      id: "",
      conversee: conversee,
      participants: [conversee.uid!, _me.uid],
    );
    conversation = await _initateChatConversation(conversation);
    return conversation;
  }

  Future<ChatConversation> _initateChatConversation(
      ChatConversation conversation) async {
    var ref = _firestore.collection(_chatConversationCollection).doc();
    conversation = conversation.copyWith(id: ref.id);
    await ref.set(conversation.toJson());
    return conversation;
  }

  Stream<Map<String, dynamic>?> fetchConverseeOnlineStatus(
      String converseeUid) {
    return _realtimeDatabase
        .ref("$_onlineChatUsersPath/$converseeUid")
        .onValue
        .map(_parseConverseeStatus);
  }

  Map<String, dynamic>? _parseConverseeStatus(DatabaseEvent event) {
    dynamic data = event.snapshot.value;
    if (data != null) {
      return {
        "isActive": true,
        "isTyping": data["with"] == _me.uid && data["isTyping"] == true
      };
    }
    return null;
  }

  Future<List<UserAccount>> searchUsersByEmail(String? email) async {
    final lowerPrefix = email?.toLowerCase() ?? "";
    final upperPrefix = '$lowerPrefix\uf8ff';
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(_usersCollectionPath)
          .where('email', isGreaterThanOrEqualTo: lowerPrefix)
          .where('email', isLessThanOrEqualTo: upperPrefix)
          .get();
      List<UserAccount> results = [];

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          dynamic data = doc.data();
          if (doc.id == _me.uid) {
            continue;
          }
          data["uid"] = doc.id;
          results.add(UserAccount.fromJson(data));
        }
      }
      return results;
    } catch (e) {
      //
    }
    return [];
  }

  void syncUserLastUpdatedAt() {
    _firestore
        .collection(_usersCollectionPath)
        .doc(_me.uid)
        .update({"lastUpdatedAt": FieldValue.serverTimestamp()});
  }
}
