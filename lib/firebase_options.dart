import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions ainda não foi configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_TjfaxaBsTLi3dgTlGsnGd-S9wD702ww',
    appId: '1:535784504043:android:9488f1f814abff9da45cae',
    messagingSenderId: '535784504043',
    projectId: 'reserva-labo-ifpa',
    storageBucket: 'reserva-labo-ifpa.firebasestorage.app',
  );
}