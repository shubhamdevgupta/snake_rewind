# Snake Rewind — Firebase Setup

## 1. Firebase Console

1. Open project `autocapture-2f9a7` (or create a new project).
2. Add Android app: `com.shubhamandroidev.snakerewind`
3. Download `google-services.json` → `android/app/google-services.json`

## 2. Enable services

- **Authentication**: Anonymous + Google
- **Firestore**: Production mode (see rules below)
- **Analytics**: Enabled
- **Crashlytics**: Enabled

## 3. Google Sign-In (Android)

Add your release **SHA-1** and **SHA-256** in Firebase → Project settings → Your apps.

```bash
cd android
./gradlew signingReport
```

## 4. Firestore rules (starter — tighten for production)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
      match /achievements/{id} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    match /stats/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /leaderboards/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 5. Firestore indexes

Create composite index if prompted when opening Leaderboard:

- Collection: `leaderboards/global/entries`
- Field: `score` Descending

## 6. iOS (optional)

Add iOS app in Firebase, download `GoogleService-Info.plist`, update `lib/core/firebase/firebase_options.dart` ios section.
