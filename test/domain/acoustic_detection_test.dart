import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/core/audio/audio_capture_source.dart';
import 'package:temposhot/features/live_timer/domain/noise_floor_estimator.dart';
import 'package:temposhot/features/live_timer/domain/rms_calculator.dart';
import 'package:temposhot/features/live_timer/domain/shot_detection_engine.dart';

class _Harness {
  _Harness(this.engine, this.now);

  final ShotDetectionEngine engine;
  DateTime now;

  void advance(Duration d) => now = now.add(d);
}

_Harness _buildEngine({
  double sensitivityMargin = 0.20,
  double minSplitLockoutSec = 0.15,
}) {
  var now = DateTime(2026, 1, 1);
  final engine = ShotDetectionEngine(
    minSplitLockoutSec: minSplitLockoutSec,
    clock: () => now,
    noiseFloor: NoiseFloorEstimator(sensitivityMargin: sensitivityMargin),
  );
  return _Harness(engine, now);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RmsCalculator', () {
    test('reports 1.0 for a full-scale alternating signal', () {
      expect(RmsCalculator.rms(const [1.0, -1.0, 1.0, -1.0]), closeTo(1.0, 1e-9));
    });

    test('reports 0.0 for digital silence', () {
      expect(RmsCalculator.rms(const [0.0, 0.0, 0.0, 0.0]), 0.0);
    });

    test('reports half amplitude for a half-scale alternating signal', () {
      expect(RmsCalculator.rms(const [0.5, -0.5, 0.5, -0.5]), closeTo(0.5, 1e-9));
    });

    test('handles empty list gracefully', () {
      expect(RmsCalculator.rms(const []), 0.0);
    });
  });

  group('NoiseFloorEstimator', () {
    test('starts at zero floor so nothing is masked before the first sample', () {
      expect(NoiseFloorEstimator().noiseFloor, 0.0);
    });

    test('tracks quiet ambient up towards it', () {
      final est = NoiseFloorEstimator(sensitivityMargin: 0.20);
      for (var i = 0; i < 40; i++) {
        est.addSample(0.05);
      }
      expect(est.noiseFloor, closeTo(0.05, 0.01));
      expect(est.threshold, closeTo(0.25, 0.01));
    });

    test('does not let a gunshot drag the floor up', () {
      final est = NoiseFloorEstimator(sensitivityMargin: 0.20);
      for (var i = 0; i < 40; i++) {
        est.addSample(0.05);
      }
      final floorBefore = est.noiseFloor;
      est.addSample(0.95);
      expect(est.noiseFloor, floorBefore);
    });

    test('a loud room raises the floor so the same shot no longer trips it', () {
      final est = NoiseFloorEstimator(sensitivityMargin: 0.20);
      for (var i = 0; i < 40; i++) {
        est.addSample(0.05);
      }
      expect(est.threshold, lessThan(0.6));

      final loud = NoiseFloorEstimator(sensitivityMargin: 0.20);
      for (var i = 0; i < 40; i++) {
        loud.addSample(0.50);
      }
      expect(loud.noiseFloor, closeTo(0.50, 0.02));
      expect(loud.threshold, greaterThan(0.6));
    });

    test('reset returns the floor to zero', () {
      final est = NoiseFloorEstimator();
      est.addSample(0.4);
      est.reset();
      expect(est.noiseFloor, 0.0);
    });
  });

  group('AudioCaptureSource', () {
    test('an unavailable source says so and emits nothing', () async {
      const source = UnavailableAudioCaptureSource('Microphone permission denied');
      expect(source.isAvailable, isFalse);
      expect(source.unavailableReason, 'Microphone permission denied');
      expect(await source.samples.take(1).toList(), isEmpty);
    });

    test('an available source can start and stop', () async {
      final source = SimulatedAudioCaptureSource();
      addTearDown(source.dispose);
      expect(source.isAvailable, isTrue);
      await source.start();
      expect(source.isCapturing, isTrue);
      final sample = await source.samples.first;
      expect(sample.amplitude, inInclusiveRange(0.0, 1.0));
      await source.stop();
      expect(source.isCapturing, isFalse);
    });

    test('a listener that subscribes before start() still receives samples', () async {
      final source = SimulatedAudioCaptureSource();
      addTearDown(source.dispose);

      final received = <double>[];
      final sub = source.samples.listen((s) => received.add(s.amplitude));

      await source.start();
      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(received, isNotEmpty,
          reason: 'subscribing before start() must not silently lose audio');
      expect(received.every((a) => a >= 0.0 && a <= 1.0), isTrue);

      await sub.cancel();
    });

    test('the simulated sampler stops ticking once the source is stopped', () async {
      final source = SimulatedAudioCaptureSource();
      addTearDown(source.dispose);
      final seen = <double>[];
      final sub = source.samples.listen((s) => seen.add(s.amplitude));

      await source.start();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(seen, isNotEmpty,
          reason: 'precondition: the sampler must actually be emitting');

      await source.stop();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      final before = seen.length;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(seen.length, before,
          reason: 'no sample may arrive after stop() returns');

      await sub.cancel();
    });
  });

  group('ShotDetectionEngine with an adaptive noise floor', () {
    test('starts unarmed and silent', () {
      final h = _buildEngine();
      expect(h.engine.isArmed, isFalse);
      expect(h.engine.isRunning, isFalse);
      expect(h.engine.recordedShots, isEmpty);
    });

    test('a sample below the noise floor does not register a shot', () {
      fakeAsync((async) {
        final h = _buildEngine();
        h.engine.armTimer(
          onArmed: (_) {},
          onStartBeep: () {},
          startDelay: Duration.zero,
        );
        async.elapse(Duration.zero);
        expect(h.engine.isRunning, isTrue);

        for (var i = 0; i < 40; i++) {
          h.engine.processAudioSample(0.05, eventTime: h.now);
        }
        expect(h.engine.recordedShots, isEmpty);
      });
    });

    test('REGISTERS the first shot above the noise floor', () {
      fakeAsync((async) {
        final h = _buildEngine();
        h.engine.armTimer(
          onArmed: (_) {},
          onStartBeep: () {},
          startDelay: Duration.zero,
        );
        async.elapse(Duration.zero);
        expect(h.engine.isRunning, isTrue);

        for (var i = 0; i < 40; i++) {
          h.engine.processAudioSample(0.05, eventTime: h.now);
        }

        h.advance(const Duration(milliseconds: 800));
        final fired = h.engine.processAudioSample(0.90, eventTime: h.now);

        expect(fired, isTrue, reason: 'a 0.90 gunshot over a 0.05 floor must fire');
        expect(h.engine.recordedShots.length, 1);
        expect(h.engine.recordedShots.single.shotNumber, 1);
        expect(h.engine.recordedShots.single.cumulativeTimeSec, closeTo(0.80, 0.01));
      });
    });

    test('REJECTS a second shot inside the 0.15s lockout window', () {
      fakeAsync((async) {
        final h = _buildEngine(minSplitLockoutSec: 0.15);
        h.engine.armTimer(
          onArmed: (_) {},
          onStartBeep: () {},
          startDelay: Duration.zero,
        );
        async.elapse(Duration.zero);

        for (var i = 0; i < 40; i++) {
          h.engine.processAudioSample(0.05, eventTime: h.now);
        }

        h.advance(const Duration(milliseconds: 800));
        expect(h.engine.processAudioSample(0.90, eventTime: h.now), isTrue);
        expect(h.engine.recordedShots.length, 1);

        h.advance(const Duration(milliseconds: 100));
        final echo = h.engine.processAudioSample(0.90, eventTime: h.now);

        expect(echo, isFalse, reason: '0.10s after a shot is inside the lockout');
        expect(h.engine.recordedShots.length, 1);
      });
    });

    test('ACCEPTS the next shot once the lockout window has passed', () {
      fakeAsync((async) {
        final h = _buildEngine(minSplitLockoutSec: 0.15);
        h.engine.armTimer(
          onArmed: (_) {},
          onStartBeep: () {},
          startDelay: Duration.zero,
        );
        async.elapse(Duration.zero);

        for (var i = 0; i < 40; i++) {
          h.engine.processAudioSample(0.05, eventTime: h.now);
        }

        h.advance(const Duration(milliseconds: 800));
        expect(h.engine.processAudioSample(0.90, eventTime: h.now), isTrue);

        h.advance(const Duration(milliseconds: 100));
        expect(h.engine.processAudioSample(0.90, eventTime: h.now), isFalse);

        h.advance(const Duration(milliseconds: 100));
        expect(h.engine.processAudioSample(0.90, eventTime: h.now), isTrue);
        expect(h.engine.recordedShots.length, 2);
        expect(h.engine.recordedShots[1].splitTimeSec, closeTo(0.20, 0.01));
      });
    });
  });
}
