import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PresenceService {
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DatabaseReference? _userStatusDatabaseRef;
  StreamSubscription? _connectedSubscription;
  StreamSubscription? _statusSubscription;

  Future<void> setupPresence(String uid) async {
    try {
      // Clean up any existing listeners
      await _cleanup();

      _userStatusDatabaseRef = _realtimeDb.ref().child('status').child(uid);
      final userStatusFirestoreRef = _firestore
          .collection('users')
          .doc(uid);

      // Listen for connection status
      _connectedSubscription = _realtimeDb.ref('.info/connected').onValue.listen((event) async {
        final connected = event.snapshot.value == true;
        if (!connected) {
          // When disconnected, mark as offline in Firestore
          await userStatusFirestoreRef.update({
            'isOnline': false,
            'lastSeen': FieldValue.serverTimestamp(),
          });
          return;
        }

        // When connected, set up onDisconnect handler
        await _userStatusDatabaseRef!.onDisconnect().set({
          'state': 'offline',
          'lastSeen': ServerValue.timestamp,
        });

        // Set online status in Realtime Database
        await _userStatusDatabaseRef!.set({
          'state': 'online',
          'lastSeen': ServerValue.timestamp,
        });

        // Update Firestore
        await userStatusFirestoreRef.update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      });

      // Listen for status changes in Realtime Database and sync to Firestore
      _statusSubscription = _userStatusDatabaseRef!.onValue.listen((event) async {
        final data = event.snapshot.value as Map?;
        if (data == null) return;

        final isOnline = data['state'] == 'online';
        await userStatusFirestoreRef.update({
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Error setting up presence: $e');
    }
  }

  Future<void> setOffline() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Set offline in Realtime Database
      if (_userStatusDatabaseRef != null) {
        await _userStatusDatabaseRef!.set({
          'state': 'offline',
          'lastSeen': ServerValue.timestamp,
        });
      }

      // Set offline in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error setting offline: $e');
    }
  }

  Future<void> _cleanup() async {
    await _connectedSubscription?.cancel();
    await _statusSubscription?.cancel();
    _connectedSubscription = null;
    _statusSubscription = null;
  }

  Future<void> cleanup() async {
    await setOffline();
    await _cleanup();
    _userStatusDatabaseRef = null;
  }
}

