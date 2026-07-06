// lib/models/app_info.dart
//
// Simple immutable model that carries package/version data to the
// Settings screen. Keeping it separate avoids leaking plugin types
// throughout the widget tree.

class AppInfoData {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;

  const AppInfoData({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
  });

  String get fullVersion => 'v$version ($buildNumber)';

  static const AppInfoData empty = AppInfoData(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
  );
}
