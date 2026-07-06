// lib/screens/settings_screen.dart
//
// Settings screen — About, Privacy Policy, App version, and Refresh.

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_info.dart';
import '../utils/config.dart';

class SettingsScreen extends StatefulWidget {
  final Future<void> Function() onRefreshWebsite;

  const SettingsScreen({super.key, required this.onRefreshWebsite});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppInfoData _info = AppInfoData.empty;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final pkg = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _info = AppInfoData(
        appName: pkg.appName.isNotEmpty ? pkg.appName : AppConfig.appName,
        packageName: pkg.packageName,
        version: pkg.version,
        buildNumber: pkg.buildNumber,
      );
    });
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(AppConfig.privacyPolicyUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the privacy policy.')),
      );
    }
  }

  void _showAboutSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: scheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConfig.appName,
                          style: Theme.of(ctx)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          _info.fullVersion.isEmpty
                              ? 'v1.0.0'
                              : _info.fullVersion,
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                AppConfig.appTagline,
                style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'CourseVault is a dedicated viewer for your StudyRatna '
                'courses, giving you a distraction-free, app-like experience '
                'with offline detection and pull-to-refresh.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.75),
                      height: 1.5,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(label: 'General'),
          _SettingsTile(
            icon: Icons.refresh_rounded,
            iconColor: scheme.primary,
            title: 'Refresh Website',
            subtitle: 'Reload the latest content',
            onTap: widget.onRefreshWebsite,
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: scheme.primary,
            title: 'About',
            subtitle: 'Learn more about CourseVault',
            onTap: _showAboutSheet,
          ),
          const SizedBox(height: 8),
          _SectionHeader(label: 'Legal'),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: scheme.primary,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: _openPrivacyPolicy,
          ),
          const SizedBox(height: 8),
          _SectionHeader(label: 'App Info'),
          _SettingsTile(
            icon: Icons.tag_rounded,
            iconColor: scheme.primary,
            title: 'App Version',
            subtitle: _info.fullVersion.isEmpty ? 'v1.0.0' : _info.fullVersion,
            onTap: null,
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Made with Flutter · Material 3',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
