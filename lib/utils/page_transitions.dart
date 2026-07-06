// lib/utils/page_transitions.dart
//
// Smooth Material 3 page transitions used throughout the app.

import 'package:flutter/material.dart';

/// Fade-through transition (Material 3 default for peer routes).
Route<T> fadeThroughRoute<T>(Widget page, {Duration? duration}) {
  return PageRouteBuilder<T>(
    transitionDuration: duration ?? const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
