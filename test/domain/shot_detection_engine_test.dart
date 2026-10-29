import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/features/live_timer/domain/shot_detection_engine.dart';

class _ClockedEngine {
  _ClockedEngine() {
    engine = ShotDetectionEngine(
      minSplitLockoutSec: 0.15,
      clock: () => _now,
    );
  }

  late final ShotDetectionEngine engine;
  DateTime _now = DateTime(2026, 1, 1);

  void arm(FakeAsync async) {
    engine.armTimer(
      onArmed: (_) {},
      onStartBeep: () {},
      startDelay: Duration.zero,
    );
    async.elapse(Duration.zero);
  }

  void fireShotAt(int offsetMs, {double amplitude = 0.90}) {
    _now = _now.add(Duration(milliseconds: offsetMs - _elapsedMs));
    _elapsedMs = offsetMs;
    engine.processAudioSample(amplitude, eventTime: _now);
  }

  int _elapsedMs = 0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShotDetectionEngine.deleteShot', () {
    test('removing the first shot promotes the second and shifts the rest', () {
      fakeAsync((async) {
        final h = _ClockedEngine();
        h.arm(async);

        h.fireShotAt(1000);
        h.fireShotAt(1300);
        h.fireShotAt(1600);

        expect(h.engine.recordedShots.length, 3);
        expect(h.engine.recordedShots[0].splitTimeSec, closeTo(1.00, 0.01));
        expect(h.engine.recordedShots[1].splitTimeSec, closeTo(0.30, 0.01));
        expect(h.engine.recordedShots[2].splitTimeSec, closeTo(0.30, 0.01));

        h.engine.deleteShot(0);

        final after = h.engine.recordedShots;
        expect(after.length, 2);
        expect(after[0].shotNumber, 1);
        expect(after[0].splitTimeSec, closeTo(1.30, 0.01),
            reason: 'the new first shot owns the whole 1.30s');
        expect(after[1].shotNumber, 2);
        expect(after[1].splitTimeSec, closeTo(0.30, 0.01));
      });
    });

    test('removing a middle shot leaves the others renumbered', () {
      fakeAsync((async) {
        final h = _ClockedEngine();
        h.arm(async);

        h.fireShotAt(1000);
        h.fireShotAt(1300);
        h.fireShotAt(1600);

        h.engine.deleteShot(1);

        final after = h.engine.recordedShots;
        expect(after.length, 2);
        expect(after[0].shotNumber, 1);
        expect(after[1].shotNumber, 2);
        expect(after[1].splitTimeSec, closeTo(0.60, 0.01),
            reason: '1600ms minus the remaining 1000ms shot');
      });
    });

    test('deleting from an empty session is a no-op', () {
      final engine = ShotDetectionEngine();
      engine.deleteShot(0);
      expect(engine.recordedShots, isEmpty);
    });

    test('deleting out of bounds index is safely ignored', () {
      fakeAsync((async) {
        final h = _ClockedEngine();
        h.arm(async);
        h.fireShotAt(1000);
        expect(h.engine.recordedShots.length, 1);

        h.engine.deleteShot(-1);
        expect(h.engine.recordedShots.length, 1);

        h.engine.deleteShot(5);
        expect(h.engine.recordedShots.length, 1);
      });
    });
  });

  group('ShotDetectionEngine reset and stop', () {
    test('reset clears recorded shots and stops running', () {
      fakeAsync((async) {
        final h = _ClockedEngine();
        h.arm(async);
        h.fireShotAt(1000);
        expect(h.engine.recordedShots.length, 1);
        expect(h.engine.isRunning, isTrue);

        h.engine.reset();
        expect(h.engine.recordedShots, isEmpty);
        expect(h.engine.isRunning, isFalse);
        expect(h.engine.isArmed, isFalse);
      });
    });

    test('stopSession retains shots but prevents new shots until re-armed', () {
      fakeAsync((async) {
        final h = _ClockedEngine();
        h.arm(async);
        h.fireShotAt(1000);
        expect(h.engine.recordedShots.length, 1);

        h.engine.stopSession();
        expect(h.engine.isRunning, isFalse);

        h.fireShotAt(2000);
        expect(h.engine.recordedShots.length, 1,
            reason: 'stopped session must not record new shots');
      });
    });
  });
}
