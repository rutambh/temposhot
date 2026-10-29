import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available product editions for TempoShot.
enum AppFlavor {
  lite,
  pro,
}

/// Centralized configuration for edition-specific limits, capabilities, and store links.
///
/// Every paywall limit, upgrade URL, and edition distinction resides HERE.
/// Nothing is hardcoded or scattered across widget files.
class AppFlavorConfig {
  final AppFlavor flavor;
  final String appName;
  final String packageName;
  final int? maxSavedStrings;
  final bool canCreateCustomDrills;
  final bool canExportData;
  final String proPlayStoreUrl;
  final double minSplitLockoutSec;
  final double defaultSensitivityThreshold;

  const AppFlavorConfig({
    required this.flavor,
    required this.appName,
    required this.packageName,
    required this.maxSavedStrings,
    required this.canCreateCustomDrills,
    required this.canExportData,
    required this.proPlayStoreUrl,
    this.minSplitLockoutSec = 0.15,
    this.defaultSensitivityThreshold = 0.65,
  });

  bool get isPro => flavor == AppFlavor.pro;
  bool get isLite => flavor == AppFlavor.lite;

  /// Default configuration for the Lite edition.
  static const AppFlavorConfig lite = AppFlavorConfig(
    flavor: AppFlavor.lite,
    appName: 'TempoShot',
    packageName: 'com.rutambh.temposhot',
    maxSavedStrings: 10,
    canCreateCustomDrills: false,
    canExportData: false,
    proPlayStoreUrl:
        'https://play.google.com/store/apps/details?id=com.rutambh.temposhot.pro',
    minSplitLockoutSec: 0.15,
    defaultSensitivityThreshold: 0.65,
  );

  /// Default configuration for the Pro edition.
  static const AppFlavorConfig pro = AppFlavorConfig(
    flavor: AppFlavor.pro,
    appName: 'TempoShot Pro',
    packageName: 'com.rutambh.temposhot.pro',
    maxSavedStrings: null, // Unlimited
    canCreateCustomDrills: true,
    canExportData: true,
    proPlayStoreUrl:
        'https://play.google.com/store/apps/details?id=com.rutambh.temposhot.pro',
    minSplitLockoutSec: 0.15,
    defaultSensitivityThreshold: 0.65,
  );

  /// Currently active runtime config.
  static AppFlavorConfig current = lite;

  /// Detect flavor from environment `--dart-define=FLAVOR=pro|lite`.
  static AppFlavorConfig fromEnvironment() {
    const flavorEnv = String.fromEnvironment('FLAVOR', defaultValue: 'lite');
    if (flavorEnv.toLowerCase() == 'pro') {
      current = pro;
      return pro;
    }
    current = lite;
    return lite;
  }
}

/// Riverpod provider for flavor configuration.
final flavorConfigProvider = Provider<AppFlavorConfig>((ref) {
  return AppFlavorConfig.current;
});
