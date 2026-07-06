// lib/screens/webview_screen.dart
//
// The heart of CourseVault. A fullscreen WebView that behaves as
// close to Chrome/Brave as possible: JavaScript, DOM storage,
// cookies, mixed content, media playback, geolocation, and a
// desktop-class UA. Includes:
//
//   • Live loading progress bar
//   • Pull-to-refresh
//   • Hardware back button navigates within the WebView history
//   • Offline detection (custom offline screen, auto-reload on
//     reconnect)
//   • Custom error screen when the target site fails to load
//   • A small floating "menu" button that opens Settings

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../services/connectivity_service.dart';
import '../utils/config.dart';
import '../utils/page_transitions.dart';
import '../widgets/loading_indicator.dart';
import 'error_screen.dart';
import 'offline_screen.dart';
import 'settings_screen.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  final ConnectivityService _connectivity = ConnectivityService();
  StreamSubscription<bool>? _connectivitySub;

  int _progress = 0;
  bool _isOnline = true;
  bool _hasFatalError = false;
  bool _initialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
    _initConnectivity();
  }

  // ---------------------------------------------------------------
  // Setup
  // ---------------------------------------------------------------

  void _initController() {
    // Force the Android platform implementation so we can enable
    // Android-only features (media playback, mixed content, etc.).
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setUserAgent(AppConfig.userAgent)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p),
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _hasFatalError = false;
              _progress = 5;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _progress = 100;
              _initialLoadComplete = true;
            });
          },
          onWebResourceError: (error) {
            // Only treat errors for the main frame as fatal — sub-resource
            // failures (ads, analytics, tracking pixels…) should not blow
            // the whole app up.
            if (error.isForMainFrame ?? false) {
              if (!mounted) return;
              setState(() => _hasFatalError = true);
            }
          },
          onNavigationRequest: (request) {
            // Let all http/https navigations proceed inside the WebView.
            // External schemes (mailto, tel, intent://…) could be handled
            // here with url_launcher in the future.
            return NavigationDecision.navigate;
          },
        ),
      );

    // Android-specific tuning: allow autoplay + mixed content.
    if (controller.platform is AndroidWebViewController) {
      final android = controller.platform as AndroidWebViewController;
      android.setMediaPlaybackRequiresUserGesture(false);
      AndroidWebViewController.enableDebugging(false);
    }

    controller.loadRequest(Uri.parse(AppConfig.websiteUrl));
    _controller = controller;
  }

  Future<void> _initConnectivity() async {
    _isOnline = await _connectivity.isOnline();
    if (!mounted) return;
    setState(() {});

    _connectivitySub = _connectivity.onStatusChange.listen((online) {
      if (!mounted) return;
      final wasOffline = !_isOnline;
      setState(() => _isOnline = online);
      if (online && wasOffline) {
        // Automatically reload when connectivity is restored.
        _controller.reload();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------

  Future<void> _reload() async {
    setState(() {
      _hasFatalError = false;
      _progress = 5;
    });
    await _controller.reload();
  }

  Future<void> _retry() async {
    setState(() {
      _hasFatalError = false;
      _progress = 5;
    });
    await _controller.loadRequest(Uri.parse(AppConfig.websiteUrl));
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      fadeThroughRoute(
        SettingsScreen(
          onRefreshWebsite: () async {
            Navigator.of(context).pop();
            await _reload();
          },
        ),
      ),
    );
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    // Ask the user before leaving the app.
    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Exit ${AppConfig.appName}?',
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are on the first page — pressing back again will '
              'close the app.',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Exit'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Stay'),
            ),
          ],
        ),
      ),
    );
    return shouldExit ?? false;
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Offline mode takes priority — replace the whole screen.
    if (!_isOnline) {
      return OfflineScreen(onRetry: () async {
        _isOnline = await _connectivity.isOnline();
        if (!mounted) return;
        setState(() {});
        if (_isOnline) await _reload();
      });
    }

    if (_hasFatalError) {
      return ErrorScreen(
        onRetry: _retry,
        onReload: _reload,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _handleBack();
        if (shouldExit && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          top: true,
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  WebLoadingBar(progress: _progress),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _reload,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // A single-child scroll view is required so
                          // RefreshIndicator can accept the drag gesture
                          // when the page is at the top.
                          return SingleChildScrollView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: constraints.maxHeight,
                              child: WebViewWidget(controller: _controller),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (!_initialLoadComplete)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white,
                    child: Center(
                      child: LoadingIndicator(message: 'Loading your courses…'),
                    ),
                  ),
                ),
              Positioned(
                right: 16,
                bottom: 24,
                child: _FloatingMenuButton(onPressed: _openSettings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingMenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _FloatingMenuButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 4,
      shape: const CircleBorder(),
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: Icon(Icons.tune_rounded, color: scheme.primary, size: 22),
        ),
      ),
    );
  }
}
