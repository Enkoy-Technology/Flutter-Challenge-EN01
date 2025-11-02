import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;
  final String cloudName;

  CloudinaryService({
    required String cloudName,
    required String uploadPreset,
  }) : cloudName = cloudName {
    _cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);
  }

  
  
  Future<String> uploadMedia(String filePath, String messageId) async {
    try {
      
      if (!File(filePath).existsSync()) {
        throw Exception('File not found: $filePath');
      }

      final file = File(filePath);
      final fileSize = await file.length();

      
      if (fileSize > 50 * 1024 * 1024) {
        throw Exception('File size exceeds 50MB limit');
      }

      
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          filePath,
          folder: 'chat-app/messages',
          publicId: messageId, 
          resourceType: CloudinaryResourceType.Auto,
        ),
      );

      return response.secureUrl; 
    } catch (e) {
      throw Exception('Cloudinary upload failed: ${e.toString()}');
    }
  }

  
  
  String getOptimizedImageUrl(String publicId) {
    
    return 'https://res.cloudinary.com/$cloudName/image/upload/w_500,h_500,c_fill,q_auto,f_auto/$publicId';
  }

  
  
  
  
}
