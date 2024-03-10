// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBQrmfEChs-wbFMElTGFljNcfUh0-ZsFSQ',
    appId: '1:749085801812:web:461e76ad877a803b259cc1',
    messagingSenderId: '749085801812',
    projectId: 'match-a-saurus',
    authDomain: 'match-a-saurus.firebaseapp.com',
    databaseURL: 'https://match-a-saurus-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'match-a-saurus.appspot.com',
    measurementId: 'G-6DFC25TR6P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDFHKoXc2N3RFIj8JfbJzBtzGvmY0auUKI',
    appId: '1:749085801812:android:14bc74c20b963e7c259cc1',
    messagingSenderId: '749085801812',
    projectId: 'match-a-saurus',
    databaseURL: 'https://match-a-saurus-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'match-a-saurus.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB8MfQWrwQ_47BATykpjgxezUWWfOJmims',
    appId: '1:749085801812:ios:38ce6ae746e59873259cc1',
    messagingSenderId: '749085801812',
    projectId: 'match-a-saurus',
    databaseURL: 'https://match-a-saurus-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'match-a-saurus.appspot.com',
    iosBundleId: 'com.example.memoryGame',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB8MfQWrwQ_47BATykpjgxezUWWfOJmims',
    appId: '1:749085801812:ios:f06bee9e1a171fcd259cc1',
    messagingSenderId: '749085801812',
    projectId: 'match-a-saurus',
    databaseURL: 'https://match-a-saurus-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'match-a-saurus.appspot.com',
    iosBundleId: 'com.example.memoryGame.RunnerTests',
  );
}