import '../config/app_flavor.dart';

class AppConstants {
  AppConstants._();

  static const String appTagline =
      'Offline Sports Shot Timer & Dry-Fire Par Trainer';

  static double get minSplitLockoutSec =>
      AppFlavorConfig.current.minSplitLockoutSec;
  static double get defaultSensitivityThreshold =>
      AppFlavorConfig.current.defaultSensitivityThreshold;
  static int? get liteMaxStrings =>
      AppFlavorConfig.current.maxSavedStrings;
  static String get playStoreUrl =>
      AppFlavorConfig.current.proPlayStoreUrl;
}
