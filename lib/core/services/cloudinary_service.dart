import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static const String cloudName = 'dkxnoff36';
  static const String apiKey = '321464193897924';
  static const String apiSecret = '4HWQ6e4lNzRCw8AdsexOUccdd_4';
  static const String baseUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  // Generate signature for signed upload
  static String _generateSignature(Map<String, String> params) {
    // Sort parameters by key
    final sortedKeys = params.keys.toList()..sort();
    final signatureString = sortedKeys
        .map((key) => '$key=${params[key]}')
        .join('&');
    final signatureStringWithSecret = '$signatureString$apiSecret';
    
    final bytes = utf8.encode(signatureStringWithSecret);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  // Upload image to Cloudinary using unsigned upload preset
  static Future<String> uploadImage({
    required File imageFile,
    required String folder,
    String? publicId,
    bool useUnsigned = true, // Default to unsigned
    String unsignedPreset = 'chatapp', // Use chatapp preset
  }) async {
    // Use unsigned upload (simpler and secure with preset)
    if (useUnsigned) {
      try {
        final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
        final publicIdToUse = publicId ?? '${folder}/${DateTime.now().millisecondsSinceEpoch}';
        
        // Set upload preset (unsigned)
        request.fields['upload_preset'] = unsignedPreset;
        
        // Set folder (will be automatically added by preset)
        if (folder.isNotEmpty) {
          request.fields['folder'] = folder;
        }
        
        // Set public_id if provided
        if (publicIdToUse.isNotEmpty) {
          request.fields['public_id'] = publicIdToUse;
        }
        
        // Add the image file
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(responseBody);
          return jsonResponse['secure_url'] as String;
        } else {
          throw Exception('Upload failed: $responseBody');
        }
      } catch (e) {
        // If unsigned fails, try signed upload as fallback
        return await _uploadWithSignature(
          imageFile: imageFile,
          folder: folder,
          publicId: publicId,
        );
      }
    }
    
    // Use signed upload as fallback
    return await _uploadWithSignature(
      imageFile: imageFile,
      folder: folder,
      publicId: publicId,
    );
  }

  // Signed upload with signature
  static Future<String> _uploadWithSignature({
    required File imageFile,
    required String folder,
    String? publicId,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final publicIdToUse = publicId ?? '${folder}/${timestamp}';
    
    final params = <String, String>{
      'timestamp': timestamp.toString(),
      'folder': folder,
      'public_id': publicIdToUse,
    };
    
    final signature = _generateSignature(params);
    
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.fields.addAll({
      'api_key': apiKey,
      'timestamp': timestamp.toString(),
      'signature': signature,
      'folder': folder,
      'public_id': publicIdToUse,
    });
    
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(responseBody);
      return jsonResponse['secure_url'] as String;
    } else {
      throw Exception('Failed to upload image: $responseBody');
    }
  }

  // Upload profile picture - linked to user ID
  // Uses unsigned upload preset 'chatapp' with folder 'chatapp'
  static Future<String> uploadProfilePicture({
    required File imageFile,
    required String userId,
  }) async {
    return await uploadImage(
      imageFile: imageFile,
      folder: 'profile_pictures', // Subfolder under 'chatapp' (set in preset)
      publicId: 'profile_pictures/$userId',
      useUnsigned: true,
      unsignedPreset: 'chatapp', // Your unsigned preset name
    );
  }

  // Upload chat media - linked to chat ID and message ID
  // Uses unsigned upload preset 'chatapp' with folder 'chatapp'
  static Future<String> uploadChatMedia({
    required File imageFile,
    required String chatId,
    String? messageId,
  }) async {
    final publicId = messageId != null 
        ? 'chat_media/$chatId/$messageId'
        : 'chat_media/$chatId/${DateTime.now().millisecondsSinceEpoch}';
    
    return await uploadImage(
      imageFile: imageFile,
      folder: 'chat_media', // Subfolder under 'chatapp' (set in preset)
      publicId: publicId,
      useUnsigned: true,
      unsignedPreset: 'chatapp', // Your unsigned preset name
    );
  }
}

