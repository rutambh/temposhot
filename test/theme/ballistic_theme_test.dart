import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/core/theme/ballistic_theme.dart';

double _relativeLuminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

double _contrastRatio(Color c1, Color c2) {
  final l1 = _relativeLuminance(c1);
  final l2 = _relativeLuminance(c2);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('BallisticTokens Style 01 Specification', () {
    test('light tokens match Rugged Ballistic Range (Desert Sand & Blaze Orange)', () {
      const t = BallisticTokens.light;
      expect(t.brightness, Brightness.light);
      expect(t.background, const Color(0xFFE8E4D8));
      expect(t.surface, const Color(0xFFDFD9C7));
      expect(t.primary, const Color(0xFFE24A1A));
      expect(t.text, const Color(0xFF141714));
      expect(t.textMuted, const Color(0xFF5A6054));
      expect(t.border, const Color(0xFFB5AF9C));
      expect(t.isDark, isFalse);
    });

    test('dark tokens match Rugged Ballistic Range (Tactical Basalt & Vibrant Orange)', () {
      const t = BallisticTokens.dark;
      expect(t.brightness, Brightness.dark);
      expect(t.background, const Color(0xFF141615));
      expect(t.surface, const Color(0xFF1E2220));
      expect(t.primary, const Color(0xFFFF5A26));
      expect(t.text, const Color(0xFFF4F6F2));
      expect(t.textMuted, const Color(0xFF919B8D));
      expect(t.border, const Color(0xFF343B36));
      expect(t.isDark, isTrue);
    });

    test('WCAG AA contrast: light mode text meets > 4.5:1 ratio', () {
      const t = BallisticTokens.light;
      expect(_contrastRatio(t.text, t.background), greaterThan(4.5));
      expect(_contrastRatio(t.text, t.surface), greaterThan(4.5));
      expect(_contrastRatio(t.textMuted, t.background), greaterThan(4.5));
      expect(_contrastRatio(t.textMuted, t.surface), greaterThan(4.5));
    });

    test('WCAG AA contrast: dark mode text meets > 4.5:1 ratio', () {
      const t = BallisticTokens.dark;
      expect(_contrastRatio(t.text, t.background), greaterThan(4.5));
      expect(_contrastRatio(t.text, t.surface), greaterThan(4.5));
      expect(_contrastRatio(t.textMuted, t.background), greaterThan(4.5));
      expect(_contrastRatio(t.textMuted, t.surface), greaterThan(4.5));
    });

    test('ThemeData mapping configures Material 3 and PublicSans font', () {
      final theme = createBallisticThemeData(BallisticTokens.dark);
      expect(theme.useMaterial3, isTrue);
      expect(theme.textTheme.bodyLarge?.fontFamily, 'PublicSans');
      expect(theme.scaffoldBackgroundColor, BallisticTokens.dark.background);
      expect(theme.colorScheme.primary, BallisticTokens.dark.primary);
      expect(theme.colorScheme.surface, BallisticTokens.dark.surface);
    });

    testWidgets('BallisticTheme inherited widget provides tokens down tree', (tester) async {
      BallisticTokens? resolvedTokens;

      await tester.pumpWidget(
        BallisticTheme(
          tokens: BallisticTokens.dark,
          child: Builder(
            builder: (context) {
              resolvedTokens = BallisticTokens.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolvedTokens, isNotNull);
      expect(resolvedTokens!.brightness, Brightness.dark);
      expect(resolvedTokens!.primary, BallisticTokens.dark.primary);
    });
  });
}
