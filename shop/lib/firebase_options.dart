// ЗАГЛУШКА — замените запустив: flutterfire configure
// Установка CLI: dart pub global activate flutterfire_cli

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError('Только web. Запустите: flutterfire configure');
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAaCX47JcBbzPRX67noZG13mWMY2eMaByc',
    appId: '1:313874920240:web:2f81bc2d4c80009d2a0ef5',
    messagingSenderId: '313874920240',
    projectId: 'what-kniting',
    authDomain: 'what-kniting.firebaseapp.com',
    storageBucket: 'what-kniting.firebasestorage.app',
    measurementId: 'G-4Q3L61DTHE',
  );

  // Замените значения на реальные из Firebase Console
}