import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Field Notebook Grid — the chosen visual style, expressed as one owner.
///
/// Primitive hexes live here and nowhere else. Widgets read semantic roles
/// from this class; they never name a colour literal.
class FieldNotebookTokens {
  const FieldNotebookTokens({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.grid,
    required this.border,
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.text,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.readoutFontFamily,
    required this.bodyFontFamily,
    required this.gridPitch,
  });

  final Brightness brightness;

  final Color background;
  final Color surface;
  final Color surfaceRaised;

  /// Dot-grid ink. Dark mode uses a sparser pitch so it stays calm.
  final Color grid;
  final double gridPitch;

  final Color border;

  /// Ink blue: the single accent, used for the one primary action.
  final Color primary;
  final Color onPrimary;

  /// Muted olive: status and limits.
  final Color accent;

  final Color text;
  final Color textMuted;

  final Color success;
  final Color warning;
  final Color error;

  /// A serif, so the numbers feel written down rather than computed.
  final String readoutFontFamily;
  final String bodyFontFamily;

  static const String readoutFamily = 'Newsreader';
  static const String bodyFamily = 'PublicSans';

  /// Dot-grid paper, ink blue accent, muted olive. The chosen light palette.
  static const FieldNotebookTokens light = FieldNotebookTokens(
    brightness: Brightness.light,
    background: Color(0xFFF6F3EA),
    surface: Color(0xFFFCFAF4),
    surfaceRaised: Color(0xFFFFFFFF),
    grid: Color(0xFFDDD7C6),
    gridPitch: 16,
    border: Color(0xFFDED8C7),
    primary: Color(0xFF2F4858),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF6B7355),
    text: Color(0xFF23221C),
    textMuted: Color(0xFF5A5B4E),
    success: Color(0xFF3D6B34),
    warning: Color(0xFF7A5C1E),
    error: Color(0xFF9E3B2C),
    readoutFontFamily: readoutFamily,
    bodyFontFamily: bodyFamily,
  );

  /// Lifted charcoal paper, softened sage. Designed, not an inversion.
  static const FieldNotebookTokens dark = FieldNotebookTokens(
    brightness: Brightness.dark,
    background: Color(0xFF23241F),
    surface: Color(0xFF2E302A),
    surfaceRaised: Color(0xFF34362E),
    grid: Color(0xFF34362E),
    gridPitch: 24,
    border: Color(0xFF43453D),
    primary: Color(0xFF7FA6C4),
    onPrimary: Color(0xFF1B2228),
    accent: Color(0xFFA3B08C),
    text: Color(0xFFEDEBE1),
    textMuted: Color(0xFFA0A192),
    success: Color(0xFF7FBF7A),
    warning: Color(0xFFD9B063),
    error: Color(0xFFE08070),
    readoutFontFamily: readoutFamily,
    bodyFontFamily: bodyFamily,
  );

  static FieldNotebookTokens of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  /// Tabular figures so a running timer never jitters in width.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  /// The big-number face. Defined once so every readout in the app -- live
  /// timer, string summary, logbook rows -- reads as written-down data rather
  /// than a monospace terminal. Tabular figures stop the digits jittering
  /// while the clock runs.
  TextStyle readout({
    required Color color,
    double size = 44,
    FontWeight weight = FontWeight.w600,
    double letterSpacing = 0.5,
  }) =>
      TextStyle(
        color: color,
        fontSize: size,
        fontFamily: readoutFontFamily,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        fontFeatures: tabular,
        height: 1.0,
      );

  /// Small-caps-ish field label. Positive tracking at small size is what makes
  /// it read as a written column heading instead of shouting UI chrome.
  TextStyle label({
    required Color color,
    double size = 11,
    FontWeight weight = FontWeight.w700,
    double letterSpacing = 1.2,
  }) =>
      TextStyle(
        color: color,
        fontSize: size,
        fontFamily: bodyFontFamily,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );

  /// Body copy. Capped measure comes from the callers' paddings; this only
  /// fixes size and rhythm.
  TextStyle body({
    required Color color,
    double size = 13,
    double height = 1.35,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        color: color,
        fontSize: size,
        fontFamily: bodyFontFamily,
        fontWeight: weight,
        height: height,
      );

  /// WCAG relative-luminance contrast ratio between two colours.
  double contrast(Color a, Color b) {
    final la = _luminance(a);
    final lb = _luminance(b);
    final hi = math.max(la, lb);
    final lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  static double _luminance(Color c) {
    double channel(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }
}

/// Inherited so widgets read tokens without re-deriving from the brightness.
class FieldNotebookTheme extends InheritedWidget {
  const FieldNotebookTheme({
    required this.tokens,
    required super.child,
    super.key,
  });

  final FieldNotebookTokens tokens;

  static FieldNotebookTokens of(BuildContext context) {
    final found =
        context.dependOnInheritedWidgetOfExactType<FieldNotebookTheme>();
    if (found != null) return found.tokens;
    return FieldNotebookTokens.of(context);
  }

  @override
  bool updateShouldNotify(FieldNotebookTheme oldWidget) =>
      oldWidget.tokens != tokens;
}

/// Builds a Material theme whose colours come only from [tokens].
ThemeData fieldNotebookTheme(FieldNotebookTokens tokens) {
  final scheme = ColorScheme(
    brightness: tokens.brightness,
    primary: tokens.primary,
    onPrimary: tokens.onPrimary,
    secondary: tokens.accent,
    onSecondary: tokens.onPrimary,
    surface: tokens.surface,
    onSurface: tokens.text,
    error: tokens.error,
    onError: tokens.onPrimary,
    outline: tokens.border,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: tokens.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: tokens.background,
    canvasColor: tokens.background,
    fontFamily: tokens.bodyFontFamily,
    dividerColor: tokens.border,
  );
}
