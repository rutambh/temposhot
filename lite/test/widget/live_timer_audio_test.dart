import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/data/datasources/audio_capture_source.dart';
import 'package:temposhot/presentation/live/live_timer_screen.dart';
import 'package:temposhot/presentation/providers/app_providers.dart';

/// Test-only capture source the test drives by hand. Stays in the test tree.
class _ControllableSource implements AudioCaptureSource {
  _ControllableSource({this.reason});

  final String? reason;
  final _controller = StreamController<AudioSample>.broadcast();
  bool started = false;
  bool stopped = false;
  bool disposed = false;

  @override
  bool get isAvailable => reason == null;

  @override
  String? get unavailableReason => reason;

  @override
  bool get isCapturing => started && !stopped;

  @override
  Stream<AudioSample> get samples => _controller.stream;

  @override
  Future<void> start() async => started = true;

  @override
  Future<void> stop() async => stopped = true;

  @override
  Future<void> dispose() async {
    disposed = true;
    await _controller.close();
  }

  void emit(double amplitude) =>
      _controller.add(AudioSample(amplitude: amplitude, capturedAt: DateTime.now()));
}

Widget _app(AudioCaptureSource source) {
  return ProviderScope(
    overrides: [
      audioCaptureSourceProvider.overrideWith((ref) {
        ref.onDispose(source.dispose);
        return source;
      }),
    ],
    child: const MaterialApp(home: LiveTimerScreen(sensitivity: 0.65)),
  );
}

void main() {
  /// The live timer is a phone screen. The default 800x600 test surface
  /// squeezes the splits table to nothing, so tests run at phone dimensions.
  void usePhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('a synthetic gunshot registers a shot in the splits table',
      (tester) async {
    usePhoneSurface(tester);
    final source = _ControllableSource();
    await tester.pumpWidget(_app(source));

    // Arming waits a random 1-4s; pump past the longest possible wait.
    await tester.pump(const Duration(seconds: 5));

    expect(source.started, isTrue,
        reason: 'the microphone must start when the timer arms');
    expect(find.text('#1'), findsNothing,
        reason: 'precondition: no shots recorded yet');

    source.emit(0.9);
    await tester.pump();
    await tester.pump();

    expect(find.text('#1'), findsOneWidget,
        reason: 'the captured gunshot must appear as shot #1');
  });

  testWidgets('a quiet sample does not register a shot', (tester) async {
    usePhoneSurface(tester);
    final source = _ControllableSource();
    await tester.pumpWidget(_app(source));
    await tester.pump(const Duration(seconds: 5));

    for (var i = 0; i < 20; i++) {
      source.emit(0.05);
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.text('#1'), findsNothing);
  });

  testWidgets('an unavailable microphone shows its reason', (tester) async {
    usePhoneSurface(tester);
    final source = _ControllableSource(reason: 'Microphone permission was not granted.');
    await tester.pumpWidget(_app(source));
    await tester.pump(const Duration(seconds: 5));

    expect(find.text('Microphone permission was not granted.'), findsOneWidget);
    expect(source.started, isFalse,
        reason: 'must not attempt capture the user refused');
  });

  testWidgets('leaving the screen disposes the capture source', (tester) async {
    usePhoneSurface(tester);
    final source = _ControllableSource();
    await tester.pumpWidget(_app(source));
    await tester.pump(const Duration(seconds: 5));

    expect(source.started, isTrue);

    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    await tester.pumpAndSettle();

    expect(source.disposed, isTrue,
        reason: 'no audio stream may outlive the live timer screen');
  });
}
