// lib/utils/config.dart
//
// CourseVault — Central configuration.
//
// To change the target website in the future, edit ONLY this file.
// No other source file references a hard-coded URL.

class AppConfig {
  AppConfig._();

  /// The website that will be loaded inside the WebView.
  static const String websiteUrl = 'https://s2-cdn.studyratna.cc/';

  /// App display name (used on the Settings screen).
  static const String appName = 'CourseVault';

  /// Splash tagline shown under the logo.
  static const String appTagline = 'Your Courses. One Tap Away.';

  /// Privacy policy URL (opened in the external browser from Settings).
  /// Update this if you host a dedicated policy page.
  static const String privacyPolicyUrl = 'https://s2-cdn.studyratna.cc/';

  /// Minimum time to display the splash screen (feels less jarring).
  static const Duration splashMinDuration = Duration(milliseconds: 2200);

  /// Desktop-class Chrome User-Agent for maximum website compatibility.
  /// The WebView will fall back to the system default if this is empty.
  static const String userAgent =
      'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.6367.113 Mobile Safari/537.36';
}
