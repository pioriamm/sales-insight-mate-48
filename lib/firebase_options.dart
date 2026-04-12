import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb) {
      throw UnsupportedError(
        'Este projeto está configurado apenas para Flutter Web.',
      );
    }

    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA1rCLM11l9cnOoVoP0vlIVvHUzDhyJPn0',
    appId: '1:880956152498:web:ae7979901811867f2447ab',
    messagingSenderId: '880956152498',
    projectId: 'lempecaseacessorios-6ec84',
    authDomain: 'lempecaseacessorios-6ec84.firebaseapp.com',
    databaseURL: 'https://lempecaseacessorios-6ec84-default-rtdb.firebaseio.com',
    storageBucket: 'lempecaseacessorios-6ec84.firebasestorage.app',
    measurementId: 'G-WDHPT7Y8YC',
  );
}