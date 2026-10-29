import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/core/audio/audio_capture_source.dart';
import 'package:temposhot/core/audio/cue_player.dart';
import 'package:temposhot/core/theme/ballistic_theme.dart';
import 'package:temposhot/features/dashboard/presentation/dashboard_screen.dart';
import 'package:temposhot/features/dry_fire/presentation/dry_fire_par_screen.dart';
import 'package:temposhot/features/history/domain/models/shot_string.dart';
import 'package:temposhot/features/history/presentation/history_screen.dart';
import 'package:temposhot/features/history/presentation/providers/history_providers.dart';
import 'package:temposhot/features/live_timer/presentation/live_timer_screen.dart';
import 'package:temposhot/features/live_timer/presentation/providers/live_timer_providers.dart';
import 'package:temposhot/features/paywall/presentation/pro_paywall_screen.dart';

Widget _buildResponsiveTestApp({
  required Widget child,
  required double textScaleFactor,
}) {
  return ProviderScope(
    overrides: [
      allStringsProvider.overrideWith((ref) async => <ShotString>[]),
      stringCountProvider.overrideWith((ref) async => 0),
      audioCaptureSourceProvider.overrideWith((ref) {
        final source = SimulatedAudioCaptureSource();
        ref.onDispose(source.dispose);
        return source;
      }),
    ],
    child: MaterialApp(
      theme: createBallisticThemeData(BallisticTokens.dark),
      builder: (context, widget) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: widget!,
        );
      },
      home: child,
    ),
  );
}

void main() {
  CuePlayer.enabled = false;

  final screenSizes = <String, Size>{
    'Compact (320dp)': const Size(320 * 2, 600 * 2),
    'Standard (390dp)': const Size(390 * 3, 844 * 3),
    'Tablet (768dp)': const Size(768 * 2, 1024 * 2),
  };

  final textScales = <double>[1.0, 1.5, 2.0];

  group('Responsive Matrix: No Overflow in Rugged Ballistic Layout', () {
    for (final sizeEntry in screenSizes.entries) {
      for (final scale in textScales) {
        testWidgets('DashboardScreen renders without overflow at ${sizeEntry.key} (scale $scale)',
            (tester) async {
          tester.view.physicalSize = sizeEntry.value;
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.reset);

          final overflowErrors = <FlutterErrorDetails>[];
          final previousOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            if (details.toString().contains('overflowed')) {
              overflowErrors.add(details);
            }
            previousOnError?.call(details);
          };
          addTearDown(() => FlutterError.onError = previousOnError);

          await tester.pumpWidget(
            _buildResponsiveTestApp(
              child: const DashboardScreen(showStartupDisclaimer: false),
              textScaleFactor: scale,
            ),
          );
          await tester.pumpAndSettle();

          expect(overflowErrors, isEmpty,
              reason: 'Dashboard overflowed at ${sizeEntry.key} with scale $scale');
        });

        testWidgets('DryFireParScreen renders without overflow at ${sizeEntry.key} (scale $scale)',
            (tester) async {
          tester.view.physicalSize = sizeEntry.value;
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.reset);

          final overflowErrors = <FlutterErrorDetails>[];
          final previousOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            if (details.toString().contains('overflowed')) {
              overflowErrors.add(details);
            }
            previousOnError?.call(details);
          };
          addTearDown(() => FlutterError.onError = previousOnError);

          await tester.pumpWidget(
            _buildResponsiveTestApp(
              child: const DryFireParScreen(),
              textScaleFactor: scale,
            ),
          );
          await tester.pumpAndSettle();

          expect(overflowErrors, isEmpty,
              reason: 'DryFireParScreen overflowed at ${sizeEntry.key} with scale $scale');
        });

        testWidgets('HistoryScreen renders without overflow at ${sizeEntry.key} (scale $scale)',
            (tester) async {
          tester.view.physicalSize = sizeEntry.value;
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.reset);

          final overflowErrors = <FlutterErrorDetails>[];
          final previousOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            if (details.toString().contains('overflowed')) {
              overflowErrors.add(details);
            }
            previousOnError?.call(details);
          };
          addTearDown(() => FlutterError.onError = previousOnError);

          await tester.pumpWidget(
            _buildResponsiveTestApp(
              child: const HistoryScreen(),
              textScaleFactor: scale,
            ),
          );
          await tester.pumpAndSettle();

          expect(overflowErrors, isEmpty,
              reason: 'HistoryScreen overflowed at ${sizeEntry.key} with scale $scale');
        });

        testWidgets('ProPaywallScreen renders without overflow at ${sizeEntry.key} (scale $scale)',
            (tester) async {
          tester.view.physicalSize = sizeEntry.value;
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.reset);

          final overflowErrors = <FlutterErrorDetails>[];
          final previousOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            if (details.toString().contains('overflowed')) {
              overflowErrors.add(details);
            }
            previousOnError?.call(details);
          };
          addTearDown(() => FlutterError.onError = previousOnError);

          await tester.pumpWidget(
            _buildResponsiveTestApp(
              child: const ProPaywallScreen(),
              textScaleFactor: scale,
            ),
          );
          await tester.pumpAndSettle();

          expect(overflowErrors, isEmpty,
              reason: 'ProPaywallScreen overflowed at ${sizeEntry.key} with scale $scale');
        });

        testWidgets('LiveTimerScreen renders without overflow at ${sizeEntry.key} (scale $scale)',
            (tester) async {
          tester.view.physicalSize = sizeEntry.value;
          tester.view.devicePixelRatio = 2.0;
          addTearDown(tester.view.reset);

          final overflowErrors = <FlutterErrorDetails>[];
          final previousOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            if (details.toString().contains('overflowed')) {
              overflowErrors.add(details);
            }
            previousOnError?.call(details);
          };
          addTearDown(() => FlutterError.onError = previousOnError);

          await tester.pumpWidget(
            _buildResponsiveTestApp(
              child: const LiveTimerScreen(),
              textScaleFactor: scale,
            ),
          );
          await tester.pumpAndSettle();

          expect(overflowErrors, isEmpty,
              reason: 'LiveTimerScreen overflowed at ${sizeEntry.key} with scale $scale');
        });
      }
    }
  });
}
