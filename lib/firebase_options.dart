import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

/// Firebase configuration for VyralIQ.
///
/// Web config is fully populated from the Firebase console.
/// Android and iOS configs need their platform-specific app IDs —
/// register those apps in the Firebase console and fill in the TODOs.
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
    apiKey: 'AIzaSyB3jWr4Wv2IYW9Y3v-oAJuzUsbDMo_EPsU',
    appId: '1:241278334117:web:fe9fc37c15cf1b9ea1894c',
    messagingSenderId: '241278334117',
    projectId: 'vyraliq',
    authDomain: 'vyraliq.firebaseapp.com',
    storageBucket: 'vyraliq.firebasestorage.app',
    measurementId: 'G-DGCBFGRLEW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3jWr4Wv2IYW9Y3v-oAJuzUsbDMo_EPsU',
    appId: '1:241278334117:android:ed6fd25e13c0c36da1894c',
    messagingSenderId: '241278334117',
    projectId: 'vyraliq',
    storageBucket: 'vyraliq.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB3jWr4Wv2IYW9Y3v-oAJuzUsbDMo_EPsU',
    appId: '1:241278334117:ios:3bc5f51e87ebcb6aa1894c',
    messagingSenderId: '241278334117',
    projectId: 'vyraliq',
    storageBucket: 'vyraliq.firebasestorage.app',
    iosBundleId: 'com.vyraliq.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB3jWr4Wv2IYW9Y3v-oAJuzUsbDMo_EPsU',
    appId: 'TODO_MACOS_APP_ID', // Register macOS app in Firebase console
    messagingSenderId: '241278334117',
    projectId: 'vyraliq',
    storageBucket: 'vyraliq.firebasestorage.app',
    iosBundleId: 'com.vyraliq.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB3jWr4Wv2IYW9Y3v-oAJuzUsbDMo_EPsU',
    appId: 'TODO_WINDOWS_APP_ID', // Register Windows app in Firebase console
    messagingSenderId: '241278334117',
    projectId: 'vyraliq',
    authDomain: 'vyraliq.firebaseapp.com',
    storageBucket: 'vyraliq.firebasestorage.app',
    measurementId: 'G-DGCBFGRLEW',
  );
}
