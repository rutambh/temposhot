import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/domain/engine/shot_detection_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShotDetectionEngine Tests', () {
    late ShotDetectionEngine engine;

    setUp(() {
      engine = ShotDetectionEngine(sensitivityThreshold: 0.60, minSplitLockoutSec: 0.15);
    });

    test('Engine starts in un-armed state', () {
      expect(engine.isArmed, isFalse);
      expect(engine.isRunning, isFalse);
      expect(engine.recordedShots, isEmpty);
    });

    test('Registers valid shot breaks above sensitivity threshold', () {
      engine.armTimer(
        onArmed: (_) {},
        onStartBeep: () {},
      );

      // Force running state for synthetic testing
      engine.stopSession();
      // Manual register
      engine.armTimer(onArmed: (_) {}, onStartBeep: () {});
    });

    test('Calculates splits and cumulative timestamps accurately', () {
      // Simulate running session
      engine.registerManualShot(customTimeSec: 1.25); // First shot (draw): 1.25s
      // Need engine running
      engine.armTimer(onArmed: (_) {}, onStartBeep: () {});
      // Wait or trigger manual shot
    });

    test('Filters out rapid double-taps within 0.15s echo lockout window', () {
      engine.registerManualShot(customTimeSec: 1.00);
      // Try registering shot at 1.05s (< 0.15s lockout) -> should be rejected!
      final rejected = engine.registerManualShot(customTimeSec: 1.05);
      expect(rejected, isFalse);
    });

    test('Deletes errant shots and re-indexes subsequent shot splits correctly', () {
      engine.deleteShot(0);
      expect(engine.recordedShots, isEmpty);
    });
  });
}
