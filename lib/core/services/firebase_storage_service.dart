import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        throw Exception('File does not exist at path: ${file.path}');
      }

      // Clean the path to remove any invalid characters
      final cleanPath = path.replaceAll(RegExp(r'[\[\]{}]'), '_');
      final ref = _storage.ref().child(cleanPath);
      
      // Upload file with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'max-age=3600',
      );
      
      final uploadTask = ref.putFile(file, metadata);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage Error [${e.code}]: ${e.message}');
    } catch (e) {
      throw Exception('Upload Error: $e');
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } on FirebaseException catch (e) {
      // If file doesn't exist, that's okay
      if (e.code != 'object-not-found') {
        throw Exception('Firebase Storage Error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Delete Error: $e');
    }
  }
}
