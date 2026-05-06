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

## Android release signing

The Android release build supports a local `android/key.properties` file. Copy `android/key.properties.example` to `android/key.properties` and fill in your real keystore values.

If `android/key.properties` is missing, release builds fall back to the debug signing config so local release testing still works.

## Remaining release checklist

- Confirm the final Android package name `com.breath.noise`
- Confirm the final iOS bundle identifier `com.breath.noise`
- Re-register those app IDs in Firebase and regenerate platform config files
- Create a real Android upload keystore and `android/key.properties`
- Configure iOS signing/team settings in Xcode
