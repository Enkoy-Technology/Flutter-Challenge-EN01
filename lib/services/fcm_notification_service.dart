import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class FcmNotificationService {
  static final String _projectId = dotenv.env['PROJECT_ID']!;
  static final String _fcmApiEndpoint =
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  static Map<String, dynamic> get _serviceAccountJson => {
        "type": "service_account",
        "project_id": _projectId,
        "private_key_id": dotenv.env['PRIVATE_KEY_ID'],
        "private_key": dotenv.env['PRIVATE_KEY'],
        "client_email": dotenv.env['CLIENT_EMAIL'],
        "client_id": dotenv.env['CLIENT_ID'],
        "auth_uri": dotenv.env['AUTH_URI'],
        "token_uri": dotenv.env['TOKEN_URI'],
        "auth_provider_x509_cert_url":
            dotenv.env['AUTH_PROVIDER_X509_CERT_URL'],
        "client_x509_cert_url": dotenv.env['CLIENT_X509_CERT_URL'],
        "universe_domain": dotenv.env['UNIVERSE_DOMAIN'],
      };

  static final List<String> _scopes = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/firebase.database",
    "https://www.googleapis.com/auth/firebase.messaging",
  ];

  Future<String> _getAccessToken() async {
    final client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(_serviceAccountJson),
      _scopes,
    );

    final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(_serviceAccountJson),
      _scopes,
      client,
    );

    client.close();

    return credentials.accessToken.data;
  }

  Future<bool> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    required String chatId,
    required String chatName,
    required String senderId,
    String? sound,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final payload = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'android': {
            'notification': {
              'sound': sound ?? 'default',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'sound': sound ?? 'default',
                'category': 'FLUTTER_NOTIFICATION_CLICK',
              },
            },
          },
          'data': {
            'chatId': chatId,
            'chatName': chatName,
            'senderId': senderId,
            'payload': 'chat:$chatId:${Uri.encodeComponent(chatName)}',
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmApiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
