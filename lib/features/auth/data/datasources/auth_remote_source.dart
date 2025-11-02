import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';
import '../../../../core/config/app_constants.dart';
import '../models/user_model.dart';

class AuthRemoteSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;
  final Logger _logger = Logger('AuthRemoteSource');

  Future<UserModel> register(String email, String password, String name) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = UserModel(uid: credential.user!.uid, email: email, name: name);

    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set(
      {
        ...user.toMap(),
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      },
    );

    _setupPresence(user.uid);
    return user;
  }

  Future<UserModel> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    _setupPresence(uid);

    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    return UserModel.fromMap(snapshot.data()!);
  }

  Future<void> logout() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        // ✅ Mark user offline before sign out
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .update({
              'isOnline': false,
              'lastSeen': FieldValue.serverTimestamp(),
            });
      }

      await _auth.signOut();
      _logger.info('User logged out successfully');
    } catch (e) {
      _logger.severe('Logout failed', e);
      throw Exception('Logout failed: $e');
    }
  }

  // ✅ Add this helper method
  void _setupPresence(String uid) {
    final userStatusDatabaseRef = _realtimeDb.ref().child('status').child(uid);

    final userStatusFirestoreRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid);

    // Set up presence system
    _realtimeDb.ref('.info/connected').onValue.listen((event) {
      final connected = event.snapshot.value == true;
      if (!connected) return;

      userStatusDatabaseRef
          .onDisconnect()
          .set({'state': 'offline', 'lastSeen': ServerValue.timestamp})
          .then((_) {
            userStatusDatabaseRef.set({
              'state': 'online',
              'lastSeen': ServerValue.timestamp,
            });
            userStatusFirestoreRef.update({
              'isOnline': true,
              'lastSeen': FieldValue.serverTimestamp(),
            });
          });
    });

    // Listen for disconnects to update Firestore
    userStatusDatabaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return;

      final isOnline = data['state'] == 'online';
      userStatusFirestoreRef.update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<User?> get authStateChanges {
    _logger.fine('Accessing auth state changes stream');
    return _auth.authStateChanges();
  }
}
