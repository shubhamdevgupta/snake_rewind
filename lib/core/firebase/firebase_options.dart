// Generated from android/app/google-services.json (Snake Rewind client).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Snake Rewind web is not configured for Firebase.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Firebase is not configured for $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_M5nY4aTjyoTy9ERRrbIKrvprmXLFl5s',
    appId: '1:149829529276:android:cb92a8196a14aca2a7eab9',
    messagingSenderId: '149829529276',
    projectId: 'autocapture-2f9a7',
    storageBucket: 'autocapture-2f9a7.appspot.com',
  );

  /// Add ios/Runner/GoogleService-Info.plist and update these values for iOS.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC_M5nY4aTjyoTy9ERRrbIKrvprmXLFl5s',
    appId: '1:149829529276:android:cb92a8196a14aca2a7eab9',
    messagingSenderId: '149829529276',
    projectId: 'autocapture-2f9a7',
    storageBucket: 'autocapture-2f9a7.appspot.com',
    iosBundleId: 'com.shubhamandroidev.snakerewind',
  );
}
