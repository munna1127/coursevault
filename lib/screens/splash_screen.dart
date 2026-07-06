// lib/screens/splash_screen.dart
//
// Modern Material 3 splash screen with a soft gradient background,
// an animated logo (scale + fade + subtle glow) and a rotating
// progress indicator underneath. Automatically navigates to the
// WebView screen after AppConfig.splashMinDuration.

import 'package:flutter/material.dart';

import '../utils/config.dart';
import '../utils/page_transitions.dart';
import 'webview_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _logoController.forward();

    // Navigate after minimum splash duration.
    Future.delayed(AppConfig.splashMinDuration, _goToWebView);
  }

  void _goToWebView() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      fadeThroughRoute(const WebViewScreen()),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary,
              Color.lerp(scheme.primary, Colors.black, 0.35) ?? scheme.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: _LogoBadge(color: scheme.onPrimary),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _logoFade,
                      child: Text(
                        AppConfig.appName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _logoFade,
                      child: Text(
                        AppConfig.appTagline,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onPrimary
                                      .withValues(alpha: 0.85),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scheme.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A circular, glassy logo badge with a graduation-cap icon.
class _LogoBadge extends StatelessWidget {
  final Color color;
  const _LogoBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.22),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(Icons.school_rounded, size: 66, color: color),
    );
  }
}
