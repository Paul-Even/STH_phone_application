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
    apiKey: 'AIzaSyBAC0SXBCaZwecwoIs7FzXjz3NwKl5FtQM',
    appId: '1:226366120654:web:d9e07237c9d2f51d5fa69f',
    messagingSenderId: '226366120654',
    projectId: 'hera-shirt',
    authDomain: 'hera-shirt.firebaseapp.com',
    databaseURL: 'https://hera-shirt-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'hera-shirt.appspot.com',
    measurementId: 'G-HZFCMXP20P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9YneQJmxYveKCe8tZeLjlZhd6MkNW5Sk',
    appId: '1:226366120654:android:8a3cca5ccc3ee51c5fa69f',
    messagingSenderId: '226366120654',
    projectId: 'hera-shirt',
    databaseURL: 'https://hera-shirt-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'hera-shirt.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDTKTQKQ5NNNpYVoEwyG-BcMwjhQray3r0',
    appId: '1:226366120654:ios:e2676aa21ac2b0cc5fa69f',
    messagingSenderId: '226366120654',
    projectId: 'hera-shirt',
    databaseURL: 'https://hera-shirt-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'hera-shirt.appspot.com',
    iosClientId: '226366120654-nbkkn38oif71d0s9es7jp775oojtd65l.apps.googleusercontent.com',
    iosBundleId: 'com.example.sthApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDTKTQKQ5NNNpYVoEwyG-BcMwjhQray3r0',
    appId: '1:226366120654:ios:e2676aa21ac2b0cc5fa69f',
    messagingSenderId: '226366120654',
    projectId: 'hera-shirt',
    databaseURL: 'https://hera-shirt-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'hera-shirt.appspot.com',
    iosClientId: '226366120654-nbkkn38oif71d0s9es7jp775oojtd65l.apps.googleusercontent.com',
    iosBundleId: 'com.example.sthApp',
  );
}
