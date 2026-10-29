import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/core/audio/audio_capture_source.dart';
import 'package:temposhot/core/audio/cue_player.dart';
import 'package:temposhot/core/theme/ballistic_theme.dart';
import 'package:temposhot/features/live_timer/presentation/live_timer_screen.dart';
import 'package:temposhot/features/live_timer/presentation/providers/live_timer_providers.dart';

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

  void emit(double amplitude, {DateTime? time}) => _controller.add(
        AudioSample(
          amplitude: amplitude,
          capturedAt: time ?? DateTime.now(),
        ),
      );
}

Widget _buildApp(AudioCaptureSource source, {Duration? startDelay}) {
  return ProviderScope(
    overrides: [
      audioCaptureSourceProvider.overrideWith((ref) {
        ref.onDispose(source.dispose);
        return source;
      }),
    ],
    child: MaterialApp(
      theme: createBallisticThemeData(BallisticTokens.dark),
      home: LiveTimerScreen(testStartDelay: startDelay ?? Duration.zero),
    ),
  );
}

void main() {
  CuePlayer.enabled = false;

  void usePhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  group('LiveTimerScreen Audio & Interaction', () {
    testWidgets('arms and detects synthetic gunshot in splits table', (tester) async {
      usePhoneSurface(tester);
      final source = _ControllableSource();
      await tester.pumpWidget(_buildApp(source, startDelay: Duration.zero));
      await tester.pumpAndSettle();

      expect(find.text('ARM TIMER · STAND BY'), findsOneWidget);
      expect(source.started, isTrue);

      // Tap ARM button
      await tester.tap(find.text('ARM TIMER · STAND BY'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('STOP & REVIEW STRING'), findsOneWidget);
      expect(find.text('#01'), findsNothing);

      // Emit loud gunshot
      source.emit(0.95);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('#01'), findsOneWidget);
    });

    testWidgets('quiet sample below threshold does not register a shot', (tester) async {
      usePhoneSurface(tester);
      final source = _ControllableSource();
      await tester.pumpWidget(_buildApp(source, startDelay: Duration.zero));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ARM TIMER · STAND BY'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Emit quiet ambient noise
      for (var i = 0; i < 10; i++) {
        source.emit(0.04);
        await tester.pump(const Duration(milliseconds: 30));
      }

      expect(find.text('#01'), findsNothing);
    });

    testWidgets('manual shot button registers a shot immediately', (tester) async {
      usePhoneSurface(tester);
      final source = _ControllableSource();
      await tester.pumpWidget(_buildApp(source, startDelay: Duration.zero));
      await tester.pumpAndSettle();

      await tester.tap(find.text('+ MANUAL SHOT'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('#01'), findsOneWidget);
    });

    testWidgets('displays MANUAL badge when audio source is unavailable', (tester) async {
      usePhoneSurface(tester);
      final source = _ControllableSource(reason: 'Microphone permission denied');
      await tester.pumpWidget(_buildApp(source));
      await tester.pumpAndSettle();

      expect(find.text('MANUAL'), findsOneWidget);
    });

    testWidgets('leaving screen disposes audio capture source', (tester) async {
      usePhoneSurface(tester);
      final source = _ControllableSource();
      await tester.pumpWidget(_buildApp(source));
      await tester.pumpAndSettle();

      expect(source.started, isTrue);

      // Pop or replace with blank widget
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      expect(source.disposed, isTrue);
    });
  });
}
