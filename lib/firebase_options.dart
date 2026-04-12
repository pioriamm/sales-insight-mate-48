import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Firebase config loaded from --dart-define values.
///
/// Example:
/// flutter run -d chrome \
///   --dart-define=FIREBASE_API_KEY=... \
///   --dart-define=FIREBASE_APP_ID=... \
///   --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
///   --dart-define=FIREBASE_PROJECT_ID=...
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are configured only for Flutter Web in this project.',
      );
    }

    _assertRequiredFirebaseDefines();
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: ''),
    messagingSenderId: String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '',
    ),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: ''),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: ''),
    databaseURL: String.fromEnvironment('FIREBASE_DATABASE_URL', defaultValue: ''),
    storageBucket: String.fromEnvironment(
      'FIREBASE_STORAGE_BUCKET',
      defaultValue: '',
    ),
    measurementId: String.fromEnvironment(
      'FIREBASE_MEASUREMENT_ID',
      defaultValue: '',
    ),
  );

  static void _assertRequiredFirebaseDefines() {
    final missing = <String>[];

    if (web.apiKey.isEmpty) missing.add('FIREBASE_API_KEY');
    if (web.appId.isEmpty) missing.add('FIREBASE_APP_ID');
    if (web.messagingSenderId.isEmpty) {
      missing.add('FIREBASE_MESSAGING_SENDER_ID');
    }
    if (web.projectId.isEmpty) missing.add('FIREBASE_PROJECT_ID');

    if (missing.isNotEmpty) {
      throw StateError(
        'Missing Firebase --dart-define values: ${missing.join(', ')}',
      );
    }
  }
}
