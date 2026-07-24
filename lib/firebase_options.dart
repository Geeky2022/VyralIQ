import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// Firebase configuration for VyralIQ.
///
/// To get real config values, go to the Firebase Console →
/// Project Settings → Your apps → Web app → Config (the firebaseConfig object).
/// Then update the TODO placeholders below with the actual values.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TODO_REPLACE_WITH_WEB_API_KEY',          // e.g. AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXX
    appId: 'TODO_REPLACE_WITH_WEB_APP_ID',             // e.g. 1:123456789012:web:abcdef1234567890
    messagingSenderId: 'TODO_REPLACE_WITH_MESSAGING_SENDER_ID', // e.g. 123456789012
    projectId: 'vyraliq',
    authDomain: 'vyraliq.firebaseapp.com',
    storageBucket: 'vyraliq.appspot.com',
    measurementId: 'TODO_REPLACE_WITH_MEASUREMENT_ID', // e.g. G-XXXXXXXXXX
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO_REPLACE_WITH_ANDROID_API_KEY',      // e.g. AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXX
    appId: 'TODO_REPLACE_WITH_ANDROID_APP_ID',         // e.g. 1:123456789012:android:abcdef1234567890
    messagingSenderId: 'TODO_REPLACE_WITH_MESSAGING_SENDER_ID', // e.g. 123456789012
    projectId: 'vyraliq',
    storageBucket: 'vyraliq.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO_REPLACE_WITH_IOS_API_KEY',          // e.g. AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXX
    appId: 'TODO_REPLACE_WITH_IOS_APP_ID',             // e.g. 1:123456789012:ios:abcdef1234567890
    messagingSenderId: 'TODO_REPLACE_WITH_MESSAGING_SENDER_ID', // e.g. 123456789012
    projectId: 'vyraliq',
    storageBucket: 'vyraliq.appspot.com',
    iosBundleId: 'TODO_REPLACE_WITH_IOS_BUNDLE_ID',    // e.g. com.vyraliq.app
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'TODO_REPLACE_WITH_MACOS_API_KEY',        // e.g. AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXX
    appId: 'TODO_REPLACE_WITH_MACOS_APP_ID',           // e.g. 1:123456789012:ios:abcdef1234567890
    messagingSenderId: 'TODO_REPLACE_WITH_MESSAGING_SENDER_ID', // e.g. 123456789012
    projectId: 'vyraliq',
    storageBucket: 'vyraliq.appspot.com',
    iosBundleId: 'TODO_REPLACE_WITH_MACOS_BUNDLE_ID',  // e.g. com.vyraliq.app
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'TODO_REPLACE_WITH_WINDOWS_API_KEY',      // e.g. AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXX
    appId: 'TODO_REPLACE_WITH_WINDOWS_APP_ID',         // e.g. 1:123456789012:web:abcdef1234567890
    messagingSenderId: 'TODO_REPLACE_WITH_MESSAGING_SENDER_ID', // e.g. 123456789012
    projectId: 'vyraliq',
    authDomain: 'vyraliq.firebaseapp.com',
    storageBucket: 'vyraliq.appspot.com',
    measurementId: 'TODO_REPLACE_WITH_MEASUREMENT_ID', // e.g. G-XXXXXXXXXX
  );
}
