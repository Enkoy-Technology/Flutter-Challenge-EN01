import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference get _usersCollection => _firestore.collection('users');

  Future<void> createUserProfile(
      String userId, String email, String name, String password) async {
    try {
      await _usersCollection.doc(userId).set({
        'email': email,
        'name': name,
        'password': password, 
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    await _usersCollection.doc(userId).update(data);
  }

  Future<void> updateUserFcmToken(String userId, String token) async {
    await _usersCollection.doc(userId).update({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUserPresence(String userId, bool isOnline) async {
    await _usersCollection.doc(userId).update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setUserOnline(String userId) async {
    await updateUserPresence(userId, true);
  }

  Future<void> setUserOffline(String userId) async {
    await updateUserPresence(userId, false);
  }

  Stream<List<User>> getAllUsers(String currentUserId) {
    return _usersCollection
        .where('email', isGreaterThan: '')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) => doc.id != currentUserId).map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return User(
          id: doc.id,
          email: data['email'] ?? '',
          name: data['name'] ?? '',
        );
      }).toList();
    });
  }

  Future<List<User>> searchUsers(String query, String currentUserId) async {
    final snapshot = await _usersCollection.get();
    final allUsers =
        snapshot.docs.where((doc) => doc.id != currentUserId).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return User(
        id: doc.id,
        email: data['email'] ?? '',
        name: data['name'] ?? '',
      );
    }).toList();

    if (query.isEmpty) {
      return allUsers;
    }

    final lowerQuery = query.toLowerCase();
    return allUsers.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<void> deleteUserData(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();

      final messagesSnapshot = await _firestore
          .collection('messages')
          .where('senderId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      final recipientMessagesSnapshot = await _firestore
          .collection('messages')
          .where('recipientId', isEqualTo: userId)
          .get();

      final recipientBatch = _firestore.batch();
      for (final doc in recipientMessagesSnapshot.docs) {
        recipientBatch.delete(doc.reference);
      }
      await recipientBatch.commit();

      final chatsSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();

      final chatsBatch = _firestore.batch();
      for (final doc in chatsSnapshot.docs) {
        chatsBatch.delete(doc.reference);
      }
      await chatsBatch.commit();
    } catch (e) {
      rethrow;
    }
  }
}
