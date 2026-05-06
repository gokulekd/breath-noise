# Breath Noise

Breath Noise is a Flutter app for ambient focus, relaxation, and sleep audio experiences. The project includes mobile app clients, Firebase configuration, and a simple marketing/legal website under `website/`.

## Requirements

- Flutter 3.x
- Dart 3.x
- Xcode for iOS builds
- Android Studio / Android SDK for Android builds

## Run locally

```bash
flutter pub get
flutter run
```

## Verify

```bash
flutter analyze
flutter test
```

## Firebase setup

Firebase is already wired into the app through:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

If you change the Android `applicationId` or iOS bundle identifier, regenerate the Firebase app configs first so they stay aligned with the registered app IDs.

### Google Sign-In checklist

The Flutter code now supports Google Sign-In through Firebase Auth, but the checked-in mobile Firebase config files are still missing OAuth client entries. Before Android or iOS Google login can work, finish these steps in Firebase:

1. Enable the `Google` provider in `Firebase Console -> Authentication -> Sign-in method`.
2. Add your Android SHA-1 and SHA-256 fingerprints to the `com.breath.noise` Android app in Firebase.
3. Re-download `android/app/google-services.json` after the fingerprints are saved. The file should contain non-empty `oauth_client` entries.
4. Re-download `ios/Runner/GoogleService-Info.plist` after enabling Google Sign-In. The file should include the Google client ID values used for iOS sign-in.
5. If Firebase prompts you to, run `flutterfire configure` again so generated options stay in sync.

Without those console-side steps, the app will build but Google login on mobile will fail with a configuration error.

## Android release signing

The Android release build supports a local `android/key.properties` file. Copy `android/key.properties.example` to `android/key.properties` and fill in your real keystore values.

If `android/key.properties` is missing, release builds fall back to the debug signing config so local release testing still works.

## Remaining release checklist

- Confirm the final Android package name `com.breath.noise`
- Confirm the final iOS bundle identifier `com.breath.noise`
- Re-register those app IDs in Firebase and regenerate platform config files
- Create a real Android upload keystore and `android/key.properties`
- Configure iOS signing/team settings in Xcode
