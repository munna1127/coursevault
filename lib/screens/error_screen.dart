// lib/screens/error_screen.dart
//
// Custom error screen shown when the target website fails to load
// (DNS failure, timeout, HTTP 5xx, etc.).

import 'package:flutter/material.dart';

import '../widgets/status_screen.dart';

class ErrorScreen extends StatelessWidget {
  final Future<void> Function() onRetry;
  final Future<void> Function() onReload;

  const ErrorScreen({
    super.key,
    required this.onRetry,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return StatusScreen(
      icon: Icons.cloud_off_rounded,
      iconColor: Theme.of(context).colorScheme.error,
      title: 'Something went wrong',
      message:
          'We couldn\'t load the website right now. Please check your '
          'connection or try again in a moment.',
      primaryLabel: 'Retry',
      onPrimary: () => onRetry(),
      secondaryLabel: 'Reload',
      onSecondary: () => onReload(),
    );
  }
}
