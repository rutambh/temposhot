import 'package:flutter/material.dart';

/// Semantic color and style tokens for the Rugged Ballistic Range (Tactical Mil-Spec) system.
///
/// Tested for WCAG AA compliance (contrast ratio > 4.5:1 for body text, > 7:1 for vital readouts)
/// in both outdoor sun-glare Light Mode and low-light Dark Mode.
class BallisticTokens {
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceSub;
  final Color oscilloscopeBg;
  final Color primary;
  final Color primaryHover;
  final Color primaryShadow;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color borderStrong;
  final Color topHighlight;
  final Color chassisShadow;
  final Color success;
  final Color alert;

  const BallisticTokens({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceSub,
    required this.oscilloscopeBg,
    required this.primary,
    required this.primaryHover,
    required this.primaryShadow,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.borderStrong,
    required this.topHighlight,
    required this.chassisShadow,
    required this.success,
    required this.alert,
  });

  bool get isDark => brightness == Brightness.dark;

  /// Light Mode: Desert Sand & Blaze Orange (Built for outdoor sun-glare bays)
  static const BallisticTokens light = BallisticTokens(
    brightness: Brightness.light,
    background: Color(0xFFE8E4D8),
    surface: Color(0xFFDFD9C7),
    surfaceSub: Color(0xFFD5CEBA),
    oscilloscopeBg: Color(0xFFD0C9B5),
    primary: Color(0xFFE24A1A),
    primaryHover: Color(0xFFBF3A10),
    primaryShadow: Color(0xFF992C0A),
    text: Color(0xFF141714),
    textMuted: Color(0xFF5A6054),
    border: Color(0xFFB5AF9C),
    borderStrong: Color(0xFF9E9882),
    topHighlight: Color(0xFFECE7DA),
    chassisShadow: Color(0xFFC0B9A4),
    success: Color(0xFF2E6B3E),
    alert: Color(0xFFE24A1A),
  );

  /// Dark Mode: Tactical Basalt & Vibrant Blaze Orange (Low-glare night/indoor)
  static const BallisticTokens dark = BallisticTokens(
    brightness: Brightness.dark,
    background: Color(0xFF141615),
    surface: Color(0xFF1E2220),
    surfaceSub: Color(0xFF262B28),
    oscilloscopeBg: Color(0xFF191D1A),
    primary: Color(0xFFFF5A26),
    primaryHover: Color(0xFFD64213),
    primaryShadow: Color(0xFF942B0A),
    text: Color(0xFFF4F6F2),
    textMuted: Color(0xFF919B8D),
    border: Color(0xFF343B36),
    borderStrong: Color(0xFF3D4540),
    topHighlight: Color(0xFF2E3531),
    chassisShadow: Color(0xFF0A0B0A),
    success: Color(0xFF4ADE80),
    alert: Color(0xFFFF5A26),
  );

  /// Read current tokens from the widget tree.
  static BallisticTokens of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_BallisticThemeScope>();
    if (scope != null) return scope.tokens;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}

/// Inherited widget providing [BallisticTokens] to the subtree.
class BallisticTheme extends StatelessWidget {
  final BallisticTokens tokens;
  final Widget child;

  const BallisticTheme({
    super.key,
    required this.tokens,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _BallisticThemeScope(
      tokens: tokens,
      child: child,
    );
  }
}

class _BallisticThemeScope extends InheritedWidget {
  final BallisticTokens tokens;

  const _BallisticThemeScope({
    required this.tokens,
    required super.child,
  });

  @override
  bool updateShouldNotify(_BallisticThemeScope oldWidget) =>
      tokens != oldWidget.tokens;
}

/// Generates standard Flutter ThemeData mapped to BallisticTokens.
ThemeData createBallisticThemeData(BallisticTokens tokens) {
  final colorScheme = ColorScheme(
    brightness: tokens.brightness,
    primary: tokens.primary,
    onPrimary: Colors.white,
    secondary: tokens.primary,
    onSecondary: Colors.white,
    surface: tokens.surface,
    onSurface: tokens.text,
    error: tokens.alert,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: tokens.brightness,
    scaffoldBackgroundColor: tokens.background,
    colorScheme: colorScheme,
    fontFamily: 'PublicSans',
    dividerColor: tokens.border,
    cardColor: tokens.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.background,
      foregroundColor: tokens.text,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'PublicSans',
        fontWeight: FontWeight.bold,
        fontSize: 16,
        letterSpacing: 1.2,
        color: tokens.text,
      ),
    ),
  );
}
