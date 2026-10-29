import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/core/config/app_flavor.dart';
import 'package:temposhot/core/theme/ballistic_theme.dart';
import 'package:temposhot/features/paywall/presentation/pro_paywall_screen.dart';
import 'package:temposhot/shared/widgets/upgrade_prompt_dialog.dart';

void main() {
  group('AppFlavorConfig Model Rules', () {
    test('Lite edition enforces strict limits', () {
      const lite = AppFlavorConfig.lite;
      expect(lite.isLite, isTrue);
      expect(lite.isPro, isFalse);
      expect(lite.maxSavedStrings, 10);
      expect(lite.canExportData, isFalse);
      expect(lite.canCreateCustomDrills, isFalse);
      expect(lite.packageName, 'com.rutambh.temposhot');
      expect(lite.proPlayStoreUrl, contains('com.rutambh.temposhot.pro'));
    });

    test('Pro edition provides unlimited storage and full features', () {
      const pro = AppFlavorConfig.pro;
      expect(pro.isLite, isFalse);
      expect(pro.isPro, isTrue);
      expect(pro.maxSavedStrings, isNull);
      expect(pro.canExportData, isTrue);
      expect(pro.canCreateCustomDrills, isTrue);
      expect(pro.packageName, 'com.rutambh.temposhot.pro');
    });
  });

  group('UpgradePromptDialog Widget', () {
    testWidgets('renders upgrade message and handles alternative action', (tester) async {
      var alternativeActionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => UpgradePromptDialog.show(
                  context,
                  title: 'Storage Limit Reached',
                  message: 'Lite stores 10 strings max. Replace oldest or upgrade.',
                  alternativeActionLabel: 'REPLACE OLDEST',
                  onAlternativeAction: () {
                    alternativeActionCalled = true;
                  },
                ),
                child: const Text('SHOW'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('SHOW'));
      await tester.pumpAndSettle();

      expect(find.text('Storage Limit Reached'), findsOneWidget);
      expect(find.text('Lite stores 10 strings max. Replace oldest or upgrade.'), findsOneWidget);
      expect(find.text('GET PRO · PLAY STORE'), findsOneWidget);
      expect(find.text('REPLACE OLDEST'), findsOneWidget);
      expect(find.text('NOT NOW'), findsOneWidget);

      await tester.tap(find.text('REPLACE OLDEST'));
      await tester.pumpAndSettle();

      expect(alternativeActionCalled, isTrue);
      expect(find.text('Storage Limit Reached'), findsNothing);
    });
  });

  group('ProPaywallScreen Widget', () {
    testWidgets('displays comparison matrix and CTA button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: createBallisticThemeData(BallisticTokens.dark),
            home: const ProPaywallScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TEMPOSHOT PRO'), findsOneWidget);
      expect(find.text('UPGRADE ON GOOGLE PLAY · \$14.99'), findsOneWidget);
      expect(find.text('Saved Strings'), findsOneWidget);
      expect(find.text('10 Max'), findsOneWidget);
      expect(find.text('Unlimited'), findsWidgets);
    });
  });
}
