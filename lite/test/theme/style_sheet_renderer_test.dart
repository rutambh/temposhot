import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/core/theme/field_notebook_theme.dart';
import 'package:temposhot/data/datasources/audio_capture_source.dart';
import 'package:temposhot/main.dart';
import 'package:temposhot/presentation/live/live_timer_screen.dart';
import 'package:temposhot/presentation/providers/app_providers.dart';

/// Renders the Field Notebook style sheet to PNGs under `build/style-sheet/`
/// so the chosen style can actually be looked at, not just asserted about.
///
/// Runs as part of `flutter test`. The output is deliberately in `build/`,
/// which is gitignored, so the suite leaves no tracked artefacts.
void main() {
  const outDir = 'build/style-sheet';

  /// flutter_test substitutes a placeholder font for every unstyled glyph, so
  /// without this the PNGs would be rows of boxes. The real TTFs are read
  /// straight off disk -- the app never fetches them.
  Future<void> loadRealFonts() async {
    for (final family in ['Newsreader', 'PublicSans']) {
      final file = File('assets/fonts/$family.ttf');
      if (!file.existsSync()) continue;
      final loader = FontLoader(family)
        ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
      await loader.load();
    }
  }

  Future<void> shoot(WidgetTester tester, String name) async {
    // Wrap the app so the whole tree is inside one repaintable boundary.
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('sheet-root')),
    );
    // toImage completes on the engine's task runner, which the test's fake
    // async zone never drains -- without runAsync this awaits forever.
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      File('$outDir/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    });
  }

  setUpAll(() async {
    Directory(outDir).createSync(recursive: true);
  });

  /// Inlines the captured PNGs into the tracked template, so the style sheet
  /// is a single self-contained file that any viewer can open.
  void writeSheet() {
    const template = 'tool/style_sheet/index.html';
    if (!File(template).existsSync()) return;
    var html = File(template).readAsStringSync();
    for (final name in [
      'dashboard-light',
      'live-timer-light',
      'dashboard-dark',
      'live-timer-dark'
    ]) {
      final png = File('$outDir/$name.png');
      if (!png.existsSync()) continue;
      final b64 = base64Encode(png.readAsBytesSync());
      html = html.replaceAll('src="$name.png"', 'src="data:image/png;base64,$b64"');
    }
    File('$outDir/sheet.html').writeAsStringSync(html);
  }

  testWidgets('render the style sheet in light and dark', (tester) async {
    await loadRealFonts();

    // The record plugin has no test implementation; the simulated source
    // keeps the live timer on its real code path.
    final source = SimulatedAudioCaptureSource();
    addTearDown(source.dispose);

    for (final brightness in Brightness.values) {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      tester.platformDispatcher.platformBrightnessTestValue = brightness;

      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('sheet-root'),
          child: ProviderScope(
            overrides: [
              audioCaptureSourceProvider.overrideWith((ref) {
                ref.onDispose(source.dispose);
                return source;
              }),
            ],
            child: TempoShotApp(key: ValueKey(brightness.name)),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('START LIVE-FIRE TIMER'), findsOneWidget,
          reason: 'precondition: the dashboard is showing');
      await shoot(tester, 'dashboard-${brightness.name}');

      // Push the live timer so the second surface is captured too.
      await tester.tap(find.text('START LIVE-FIRE TIMER'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(LiveTimerScreen), findsOneWidget,
          reason: 'precondition: the live timer was pushed');
      await shoot(tester, 'live-timer-${brightness.name}');
    }

    // Tear the tree down while a test is still active so the live timer's 30ms
    // render loop and the source's 20ms sampler are both cancelled before the
    // framework checks for pending timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await source.dispose();

    tester.platformDispatcher.clearPlatformBrightnessTestValue();
    tester.view.reset();

    // The shell survived both captures.
    expect(FieldNotebookTokens.light.readoutFontFamily, 'Newsreader');
    for (final f in [
      'dashboard-light',
      'dashboard-dark',
      'live-timer-light',
      'live-timer-dark'
    ]) {
      expect(File('$outDir/$f.png').existsSync(), isTrue,
          reason: '$f.png must have been rendered');
    }

    writeSheet();
    expect(File('$outDir/sheet.html').existsSync(), isTrue);
  });
}