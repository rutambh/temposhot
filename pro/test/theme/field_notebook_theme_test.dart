import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot_pro/core/theme/field_notebook_theme.dart';
import 'package:temposhot_pro/core/widgets/dot_grid_background.dart';
import 'package:temposhot_pro/core/widgets/paper_card.dart';
import 'package:temposhot_pro/main.dart';
import 'package:temposhot_pro/presentation/dashboard/dashboard_screen.dart';
import 'package:temposhot_pro/presentation/live/live_timer_screen.dart';

void main() {
  group('FieldNotebookTokens', () {
    test('light palette matches the chosen Style 9 values', () {
      const t = FieldNotebookTokens.light;
      expect(t.background, const Color(0xFFF6F3EA));
      expect(t.surface, const Color(0xFFFCFAF4));
      expect(t.grid, const Color(0xFFDDD7C6));
      expect(t.border, const Color(0xFFDED8C7));
      expect(t.primary, const Color(0xFF2F4858));
      expect(t.accent, const Color(0xFF6B7355));
      expect(t.text, const Color(0xFF23221C));
      expect(t.textMuted, const Color(0xFF5A5B4E));
    });

    test('dark palette matches the chosen Style 9 values', () {
      const t = FieldNotebookTokens.dark;
      expect(t.background, const Color(0xFF23241F));
      expect(t.surface, const Color(0xFF2E302A));
      expect(t.grid, const Color(0xFF34362E));
      expect(t.border, const Color(0xFF43453D));
      expect(t.primary, const Color(0xFF7FA6C4));
      expect(t.accent, const Color(0xFFA3B08C));
      expect(t.text, const Color(0xFFEDEBE1));
      expect(t.textMuted, const Color(0xFFA0A192));
    });

    test('every token pair is legible against its own surface', () {
      for (final t in const [FieldNotebookTokens.light, FieldNotebookTokens.dark]) {
        expect(t.contrast(t.text, t.background), greaterThan(4.5));
        expect(t.contrast(t.textMuted, t.background), greaterThan(4.5));
        expect(t.contrast(t.text, t.surface), greaterThan(4.5));
        expect(t.contrast(t.primary, t.surface), greaterThan(4.5));
      }
    });

    test('the readout uses the bundled Newsreader face, not Roboto', () {
      const light = FieldNotebookTokens.light;
      expect(light.readoutFontFamily, 'Newsreader');
      expect(light.bodyFontFamily, 'PublicSans');
    });
  });

  group('surface widgets', () {
    testWidgets('DotGridBackground paints without overflowing its child',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: DotGridBackground(child: SizedBox(height: 40, child: Text('x'))),
        ),
      ));
      expect(find.byType(DotGridBackground), findsOneWidget);
      expect(find.text('x'), findsOneWidget);
    });

    test('the painter lays down paper before it draws any dot', () async {
      // Pixel-level, because this is exactly the kind of thing a
      // findsOneWidget assertion cannot see: the sheet used to paint only the
      // dots, leaving 43% of the screen transparent on the platform window
      // background instead of cream paper.
      const tokens = FieldNotebookTokens.light;
      final painter = DotGridPainter(
        background: tokens.background,
        color: tokens.grid,
        pitch: tokens.gridPitch,
      );

      final recorder = ui.PictureRecorder();
      painter.paint(Canvas(recorder), const Size(64, 64));
      final picture = recorder.endRecording();

      final image = await picture.toImage(64, 64);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      picture.dispose();
      expect(bytes, isNotNull);

      final data = bytes!.buffer.asUint8List();
      final px = bytes.lengthInBytes ~/ (64 * 64);
      var transparent = 0;
      var paper = 0;
      var dots = 0;
      for (var i = 0; i < 64 * 64; i++) {
        final o = i * px;
        final a = px == 4 ? data[o + 3] : 255;
        if (a == 0) {
          transparent++;
          continue;
        }
        final nearPaper = (data[o] - 0xF6).abs() < 6 &&
            (data[o + 1] - 0xF3).abs() < 6 &&
            (data[o + 2] - 0xEA).abs() < 6;
        final nearDot = (data[o] - 0xDD).abs() < 10 &&
            (data[o + 1] - 0xD7).abs() < 10 &&
            (data[o + 2] - 0xC6).abs() < 10;
        if (nearPaper) {
          paper++;
        } else if (nearDot) {
          dots++;
        }
      }

      expect(transparent, 0,
          reason: 'every pixel of the sheet must be painted, not left to the '
              'platform window background');
      expect(paper + dots, 64 * 64, reason: 'only paper and grid ink allowed');
      expect(paper, greaterThan(64 * 64 * 0.9),
          reason: 'the sheet must be mostly cream paper');
      expect(dots, greaterThan(0), reason: 'and the dot grid must be visible');
    });

    testWidgets('PaperCard renders its child at a narrow width', (tester) async {
      tester.view.physicalSize = const Size(320 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: PaperCard(child: Text('STORED STRINGS')),
        ),
      ));
      expect(find.text('STORED STRINGS'), findsOneWidget);
    });
  });

  group('Field Notebook treatment on real screens at 390dp', () {
    Widget app(Widget home) =>
        ProviderScope(child: MaterialApp(home: home));

    testWidgets('the dashboard renders without overflow', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflowed')) errors.add(d);
        previous?.call(d);
      };
      addTearDown(() => FlutterError.onError = previous);

      await tester.pumpWidget(app(const DashboardScreen()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('START LIVE-FIRE TIMER'), findsOneWidget);
      expect(find.byType(PaperCard), findsWidgets,
          reason: 'the dashboard must use the notebook card surface');
      expect(errors, isEmpty,
          reason: 'dashboard must not overflow at 390dp: $errors');
    });

    testWidgets('the live timer renders without overflow', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (d) {
        if (d.toString().contains('overflowed')) errors.add(d);
        previous?.call(d);
      };
      addTearDown(() => FlutterError.onError = previous);

      await tester.pumpWidget(app(const LiveTimerScreen(sensitivity: 0.65)));
      await tester.pump(const Duration(seconds: 5));

      expect(find.byType(LiveTimerScreen), findsOneWidget);
      expect(find.text('STOP & REVIEW STRING'), findsOneWidget);
      expect(errors, isEmpty,
          reason: 'live timer must not overflow at 390dp: $errors');
    });

    testWidgets('both screens actually use the notebook readout face',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app(const LiveTimerScreen(sensitivity: 0.65)));
      await tester.pump(const Duration(seconds: 5));

      final readoutFamilies = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.style?.fontFamily)
          .whereType<String>()
          .toSet();

      expect(readoutFamilies, contains('Newsreader'),
          reason: 'the big readout must be Newsreader; saw $readoutFamilies');
    });
  });

  group('the real app shell', () {
    /// The shell used to wrap `home:` only, which meant the live timer and the
    /// summary -- both pushed routes -- rendered on bare scaffold colour with
    /// no dot grid and, in dark mode, the light palette. These two tests pin
    /// the wiring that fixes that.
    for (final brightness in Brightness.values) {
      testWidgets('pushed routes get ${brightness.name} tokens and the grid',
          (tester) async {
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

        await tester.pumpWidget(const ProviderScope(child: TempoShotApp()));
        await tester.pump();

        final shell =
            tester.widget<FieldNotebookTheme>(find.byType(FieldNotebookTheme));
        expect(shell.tokens.brightness, brightness,
            reason: 'the shell must resolve tokens from the app theme');

        // Walk to the live timer, which is a pushed route.
        await tester.tap(find.text('START LIVE-FIRE TIMER'));
        await tester.pump();
        await tester.pump();

        expect(find.byType(LiveTimerScreen), findsOneWidget);
        expect(
          tester.widget<FieldNotebookTheme>(find.byType(FieldNotebookTheme)).tokens.brightness,
          brightness,
          reason: 'a pushed route must see the same tokens as the dashboard',
        );
        expect(find.byType(DotGridBackground), findsWidgets,
            reason: 'the dot grid must sit behind every route, not just home');

        // The dot grid is only visible if the scaffold does not paint over it.
        final scaffold =
            tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold.backgroundColor, Colors.transparent,
            reason: 'an opaque scaffold would hide the notebook paper');
      });
    }
  });
}
