import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(String path) {
    return _db.collection(path).orderBy('timestamp').snapshots();
  }

  Future<void> addDocument(String path, Map<String, dynamic> data) {
    return _db.collection(path).add(data);
  }

  Future<void> updateDocument(
    String path,
    String id,
    Map<String, dynamic> data,
  ) {
    return _db.collection(path).doc(id).update(data);
  }

  Future<void> deleteDocument(String path, String id) {
    return _db.collection(path).doc(id).delete();
  }
}
