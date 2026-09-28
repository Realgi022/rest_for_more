import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class InstalledApp {
  final String label;
  final String packageName;

  const InstalledApp({required this.label, required this.packageName});

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map) {
    return InstalledApp(
      label: map['label'] as String? ?? '',
      packageName: map['packageName'] as String? ?? '',
    );
  }
}

class AppBlockerService {
  static const MethodChannel _channel = MethodChannel(
    'rest_for_more/app_blocker',
  );

  static bool get isSupported {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  static Future<List<InstalledApp>> getInstalledApps() async {
    if (!isSupported) return [];

    final apps = await _channel.invokeListMethod<dynamic>('getInstalledApps');
    return apps
            ?.whereType<Map<dynamic, dynamic>>()
            .map(InstalledApp.fromMap)
            .where((app) => app.label.isNotEmpty && app.packageName.isNotEmpty)
            .toList() ??
        [];
  }

  static Future<Set<String>> getBlockedPackages() async {
    if (!isSupported) return {};

    final packages = await _channel.invokeListMethod<String>(
      'getBlockedPackages',
    );
    return packages?.toSet() ?? {};
  }

  static Future<void> setBlockedPackages(Set<String> packages) async {
    if (!isSupported) return;

    await _channel.invokeMethod<void>('setBlockedPackages', {
      'packages': packages.toList(),
    });
  }

  static Future<bool> isAccessibilityServiceEnabled() async {
    if (!isSupported) return false;

    return await _channel.invokeMethod<bool>('isAccessibilityServiceEnabled') ??
        false;
  }

  static Future<void> openAccessibilitySettings() async {
    if (!isSupported) return;

    await _channel.invokeMethod<void>('openAccessibilitySettings');
  }
}
