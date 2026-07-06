// lib/widgets/loading_indicator.dart
//
// A polished, brand-aware loading indicator used across the app.

import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 18),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ],
      ],
    );
  }
}

/// Thin, animated linear progress bar shown at the top of the WebView
/// while a page is loading. Automatically hides at 100%.
class WebLoadingBar extends StatelessWidget {
  final int progress; // 0..100

  const WebLoadingBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = progress > 0 && progress < 100;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: visible ? 1 : 0,
      child: SizedBox(
        height: 3,
        child: LinearProgressIndicator(
          value: progress / 100.0,
          minHeight: 3,
          backgroundColor: scheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
        ),
      ),
    );
  }
}
