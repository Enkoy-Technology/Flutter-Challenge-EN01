import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
     
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for this platform.',
        );
    }
  }


  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['ANDROID_API_KEY']!,
        appId: dotenv.env['ANDROID_APP_ID']!,
        messagingSenderId: dotenv.env['ANDROID_MESSAGING_SENDER_ID']!,
        projectId: dotenv.env['ANDROID_PROJECT_ID']!,
        databaseURL: dotenv.env['ANDROID_DATABASE_URL'],
        storageBucket: dotenv.env['ANDROID_STORAGE_BUCKET'],
      );

}
