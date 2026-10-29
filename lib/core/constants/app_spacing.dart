import 'package:flutter/material.dart';

/// Semantic spacing tokens for consistent visual rhythm across all screens.
/// No magic numbers allowed in widget layouts.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // Corner radius tokens
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusPill = 999.0;

  // Accessibility & touch target tokens
  static const double minTouchTarget = 48.0;
  static const double primaryButtonHeight = 64.0;
  static const double secondaryButtonHeight = 48.0;
  static const double statusBadgeHeight = 32.0;
  static const double navBarHeight = 64.0;

  // Standard EdgeInsets utilities
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: xl, vertical: lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: xxl, vertical: md);
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(horizontal: md, vertical: xs);
}
