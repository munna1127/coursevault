# CourseVault

A dedicated, distraction-free Android course viewer for **StudyRatna**, built with **Flutter + Material 3**.

CourseVault opens directly into a fullscreen WebView pointing to your course website — no login, no signup, no browser chrome. It ships with a modern splash screen, offline detection, pull-to-refresh, a custom error screen, and a Settings screen.

---

## Features

- Fullscreen Chrome-parity WebView (JavaScript, DOM storage, cookies, local storage, media playback, mixed content, desktop-class User-Agent)
- Splash screen with animated logo (fade + scale) and loading indicator
- Live page-load progress bar
- Pull-to-refresh
- Hardware back navigates within the WebView history; asks before exiting
- Portrait + landscape support
- **Custom offline screen** with Retry (auto-reloads once the connection returns)
- **Custom error screen** with Retry / Reload
- Settings screen: About, Privacy Policy, App Version, Refresh Website
- Material 3 theme (light + dark, follows system)
- Smooth fade-through page transitions
- Single-source website URL configuration (`lib/utils/config.dart`)
- Clean architecture: `screens/`, `services/`, `widgets/`, `models/`, `utils/`
- Null-safety, `flutter_lints` enforced, no `TODO`s, no placeholder code

---

## Project Structure

```
coursevault/
├── android/                       # Android platform code + Gradle config
│   ├── app/
│   │   ├── build.gradle
│   │   ├── proguard-rules.pro
│   │   └── src/
│   │       ├── main/
│   │       │   ├── AndroidManifest.xml
│   │       │   ├── kotlin/com/coursevault/app/MainActivity.kt
│   │       │   └── res/
│   │       │       ├── drawable/launch_background.xml
│   │       │       ├── drawable-v21/launch_background.xml
│   │       │       ├── mipmap-*/ic_launcher.png
│   │       │       ├── values/styles.xml
│   │       │       └── values-night/styles.xml
│   │       ├── debug/AndroidManifest.xml
│   │       └── profile/AndroidManifest.xml
│   ├── build.gradle
│   ├── gradle.properties
│   ├── settings.gradle
│   └── gradle/wrapper/gradle-wrapper.properties
├── assets/
│   └── images/logo.png             # Launcher icon source (1024x1024)
├── lib/
│   ├── main.dart
│   ├── models/app_info.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── webview_screen.dart
│   │   ├── offline_screen.dart
│   │   ├── error_screen.dart
│   │   └── settings_screen.dart
│   ├── services/connectivity_service.dart
│   ├── utils/
│   │   ├── config.dart             # <-- change your URL here
│   │   ├── page_transitions.dart
│   │   └── theme.dart
│   └── widgets/
│       ├── loading_indicator.dart
│       └── status_screen.dart
├── analysis_options.yaml
├── pubspec.yaml
├── README.md
└── .gitignore
```

---

## Requirements

- **Flutter SDK**: 3.24 or newer (channel `stable`)
- **Dart**: bundled with Flutter (>= 3.4)
- **Android SDK**: `compileSdk 34`, `minSdk 21`
- **JDK 17** (bundled with recent Android Studio)

Run `flutter doctor` and make sure the Android toolchain is green.

---

## First-time setup

1. Extract the ZIP and `cd` into the project:
   ```bash
   cd coursevault
   ```

2. Create `android/local.properties` and point it at your Flutter SDK. (This file is intentionally not shipped in the ZIP because it's machine-specific.)

   Example on **Windows**:
   ```
   sdk.dir=C:\\Users\\<you>\\AppData\\Local\\Android\\Sdk
   flutter.sdk=C:\\src\\flutter
   flutter.buildMode=release
   flutter.versionName=1.0.0
   flutter.versionCode=1
   ```

   Example on **macOS / Linux**:
   ```
   sdk.dir=/Users/<you>/Library/Android/sdk
   flutter.sdk=/Users/<you>/development/flutter
   flutter.buildMode=release
   flutter.versionName=1.0.0
   flutter.versionCode=1
   ```

   > Tip: running `flutter run` once from the project root will auto-generate this file for you.

3. Fetch dependencies:
   ```bash
   flutter pub get
   ```

4. (Optional but recommended) Regenerate the adaptive launcher icons from `assets/images/logo.png`:
   ```bash
   dart run flutter_launcher_icons
   ```

   The 5 raster mipmaps are already included, so this step is only needed if you replace `logo.png`.

5. Build the release APK:
   ```bash
   flutter build apk --release
   ```

   The signed-with-debug-key APK will be at:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

   > For Play-Store distribution, configure a real keystore via `android/key.properties` — see the [Flutter signing docs](https://docs.flutter.dev/deployment/android#signing-the-app).

---

## Changing the website URL

Open **`lib/utils/config.dart`** and edit **one** constant:

```dart
static const String websiteUrl = 'https://s2-cdn.studyratna.cc/';
```

No other file references this URL.

---

## Common commands

| Task                              | Command                                 |
|-----------------------------------|-----------------------------------------|
| Install dependencies              | `flutter pub get`                       |
| Run on a connected device         | `flutter run`                           |
| Build release APK                 | `flutter build apk --release`           |
| Build split-per-ABI APKs (smaller)| `flutter build apk --split-per-abi`     |
| Build App Bundle (for Play Store) | `flutter build appbundle --release`     |
| Analyse code                      | `flutter analyze`                       |
| Lint fix                          | `dart fix --apply`                      |
| Regenerate launcher icons         | `dart run flutter_launcher_icons`       |

---

## Notes on WebView compatibility

CourseVault uses the official `webview_flutter` (v4) plugin, which is backed by the Android System WebView / Chrome. It is configured for maximum compatibility:

- JavaScript: unrestricted
- DOM storage & cookies: enabled by default in the Android backend
- Media autoplay: allowed (`setMediaPlaybackRequiresUserGesture(false)`)
- User-Agent: overridden to a recent Chrome-on-Android UA string
- Zoom: enabled
- Mixed content & cleartext HTTP: allowed via `android:usesCleartextTraffic="true"`

If you need file uploads, push notifications from the page, or camera/mic access from within the WebView, extend the Android configuration in `android/app/src/main/AndroidManifest.xml` and the `AndroidWebViewController` block in `lib/screens/webview_screen.dart`.

---

## License

Private / All rights reserved.
