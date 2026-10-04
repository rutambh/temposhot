import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/data/datasources/audio_capture_source.dart';
import 'package:temposhot/domain/audio/noise_floor_estimator.dart';
import 'package:temposhot/domain/audio/rms_calculator.dart';
import 'package:temposhot/domain/engine/shot_detection_engine.dart';

/// One engine wired for deterministic tests: a controllable clock, no random
/// arming delay, and an adaptive noise floor.
///
/// [now] is a live mutable field, not a record field -- a record would snapshot
/// the clock value at construction and the injected clock would never advance.
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
  // The engine fires haptic feedback on arm and on each shot break, which
  // goes through a platform channel and needs the binding to exist.
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
      // 0.6 is well above a quiet-room threshold of ~0.25.
      expect(est.threshold, lessThan(0.6));

      final loud = NoiseFloorEstimator(sensitivityMargin: 0.20);
      for (var i = 0; i < 40; i++) {
        loud.addSample(0.50);
      }
      expect(loud.noiseFloor, closeTo(0.50, 0.02));
      // Same 0.6 sample must now sit below the adapted threshold.
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
      expect(source.isAvailable, isTrue);
      await source.start();
      expect(source.isCapturing, isTrue);
      final sample = await source.samples.first;
      expect(sample.amplitude, inInclusiveRange(0.0, 1.0));
      await source.stop();
      expect(source.isCapturing, isFalse);
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

        // Train a quiet floor, then feed quiet samples only.
        // Train the floor without moving the clock, so the shot timings below
        // are measured from the start beep and nothing else.
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
        expect(h.engine.isRunning, isTrue,
            reason: 'engine must actually be running or this proves nothing');

        // Train the floor without moving the clock, so the shot timings below
        // are measured from the start beep and nothing else.
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

        // Train the floor without moving the clock, so the shot timings below
        // are measured from the start beep and nothing else.
        for (var i = 0; i < 40; i++) {
          h.engine.processAudioSample(0.05, eventTime: h.now);
        }

        h.advance(const Duration(milliseconds: 800));
        expect(h.engine.processAudioSample(0.90, eventTime: h.now), isTrue);
        expect(h.engine.recordedShots.length, 1,
            reason: 'precondition: one shot must be recorded');

        // 100ms later => 0.10s split, inside the 0.15s lockout.
        h.advance(const Duration(milliseconds: 100));
        final echo = h.engine.processAudioSample(0.90, eventTime: h.now);

        expect(echo, isFalse, reason: '0.10s after a shot is inside the lockout');
        expect(h.engine.recordedShots.length, 1,
            reason: 'the lockout must not record a second shot');
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

        // Train the floor without moving the clock, so the shot timings below
        // are measured from the start beep and nothing else.
        for (var i = 0; i < 40; i++) {
          h.engine.processAudioSample(0.05, eventTime: h.now);
        }

        h.advance(const Duration(milliseconds: 800));
        expect(h.engine.processAudioSample(0.90, eventTime: h.now), isTrue);

        h.advance(const Duration(milliseconds: 100));
        expect(h.engine.processAudioSample(0.90, eventTime: h.now), isFalse);

        // A further 100ms => 0.20s since the recorded shot, outside the lockout.
        h.advance(const Duration(milliseconds: 100));
        expect(h.engine.processAudioSample(0.90, eventTime: h.now), isTrue);
        expect(h.engine.recordedShots.length, 2);
        expect(h.engine.recordedShots[1].splitTimeSec, closeTo(0.20, 0.01));
      });
    });
  });
}
