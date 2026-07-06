// lib/widgets/status_screen.dart
//
// Reusable full-screen "status" scaffold used by both the Offline and
// Error screens — an icon, a title, a description, and one or two
// action buttons. Keeps both screens visually consistent.

import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const StatusScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.iconColor,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedIconColor = iconColor ?? scheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 108,
                height: 108,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: resolvedIconColor.withValues(alpha: 0.10),
                ),
                child: Icon(icon, size: 56, color: resolvedIconColor),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onPrimary,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(primaryLabel),
              ),
              if (secondaryLabel != null && onSecondary != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
