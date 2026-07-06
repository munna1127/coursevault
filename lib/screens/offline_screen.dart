// lib/screens/offline_screen.dart
//
// Custom offline screen — never the default WebView error page.

import 'package:flutter/material.dart';

import '../widgets/status_screen.dart';

class OfflineScreen extends StatelessWidget {
  final Future<void> Function() onRetry;

  const OfflineScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.wifi_off_rounded,
      iconColor: Theme.of(context).colorScheme.error,
      title: 'No Internet Connection',
      message:
          'Please connect to the internet and try again. CourseVault will '
          'automatically reload once your connection is back.',
      primaryLabel: 'Retry',
      onPrimary: () => onRetry(),
    );
  }
}
