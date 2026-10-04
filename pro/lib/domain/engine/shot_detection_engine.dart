import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../audio/noise_floor_estimator.dart';
import '../models/shot_record.dart';

class ShotDetectionEngine {
  /// Fixed threshold used when no [noiseFloor] estimator is supplied.
  double sensitivityThreshold;
  double minSplitLockoutSec;

  /// When set, detection uses an adaptive threshold relative to the measured
  /// room noise instead of [sensitivityThreshold].
  final NoiseFloorEstimator? noiseFloor;

  /// Injectable so timing is deterministic under test.
  final DateTime Function() _clock;
  final math.Random _random;

  final List<ShotRecord> _recordedShots = [];
  DateTime? _startBeepTime;
  Timer? _randomDelayTimer;
  bool _isArmed = false;
  bool _isRunning = false;

  ShotDetectionEngine({
    this.sensitivityThreshold = AppConstants.defaultSensitivityThreshold,
    this.minSplitLockoutSec = AppConstants.minSplitLockoutSec,
    this.noiseFloor,
    DateTime Function()? clock,
    math.Random? random,
  })  : _clock = clock ?? DateTime.now,
        _random = random ?? math.Random();

  /// Amplitude a sample must reach to count as a shot right now.
  double get detectionThreshold =>
      noiseFloor?.threshold ?? sensitivityThreshold;

  List<ShotRecord> get recordedShots => List.unmodifiable(_recordedShots);
  bool get isArmed => _isArmed;
  bool get isRunning => _isRunning;
  DateTime? get startBeepTime => _startBeepTime;

  double get totalTimeSec =>
      _recordedShots.isNotEmpty ? _recordedShots.last.cumulativeTimeSec : 0.0;

  double get firstShotDelaySec =>
      _recordedShots.isNotEmpty ? _recordedShots.first.cumulativeTimeSec : 0.0;

  void resetSession() {
    _randomDelayTimer?.cancel();
    _recordedShots.clear();
    _isArmed = false;
    _isRunning = false;
    _startBeepTime = null;
    noiseFloor?.reset();
  }

  /// Arm timer with randomized delay between 1.0s and 4.0s.
  ///
  /// [startDelay] overrides the random delay, which keeps arming deterministic
  /// under test and lets the dry-fire flow use a fixed lead-in.
  void armTimer({
    required Function(double delaySec) onArmed,
    required VoidCallback onStartBeep,
    Duration? startDelay,
  }) {
    resetSession();
    _isArmed = true;

    final delaySeconds = startDelay != null
        ? startDelay.inMilliseconds / 1000.0
        : 1.0 + _random.nextDouble() * 3.0; // 1.0 to 4.0s
    onArmed(delaySeconds);

    _randomDelayTimer = Timer(Duration(milliseconds: (delaySeconds * 1000).round()), () {
      if (!_isArmed) return;
      _isArmed = false;
      _isRunning = true;
      _startBeepTime = _clock();
      HapticFeedback.heavyImpact();
      onStartBeep();
    });
  }

  /// Process audio energy amplitude (0.0 to 1.0)
  bool processAudioSample(double amplitudeNorm, {DateTime? eventTime}) {
    if (!_isRunning || _startBeepTime == null) return false;

    final now = eventTime ?? _clock();
    final elapsedSec = now.difference(_startBeepTime!).inMicroseconds / 1000000.0;

    // Gate on the adaptive noise floor when one is configured; otherwise fall
    // back to the fixed sensitivity threshold.
    if (amplitudeNorm < detectionThreshold) {
      noiseFloor?.addSample(amplitudeNorm);
      return false;
    }

    // Check minimum split lockout window (150ms) against last shot
    if (_recordedShots.isNotEmpty) {
      final lastShot = _recordedShots.last;
      final splitFromLast = elapsedSec - lastShot.cumulativeTimeSec;
      if (splitFromLast < minSplitLockoutSec) {
        return false; // Lockout echo suppression
      }
    }

    // Register valid shot break
    final double splitTime = _recordedShots.isEmpty
        ? elapsedSec
        : elapsedSec - _recordedShots.last.cumulativeTimeSec;

    final newShot = ShotRecord(
      stringId: 0,
      shotNumber: _recordedShots.length + 1,
      splitTimeSec: double.parse(splitTime.toStringAsFixed(2)),
      cumulativeTimeSec: double.parse(elapsedSec.toStringAsFixed(2)),
    );

    _recordedShots.add(newShot);
    HapticFeedback.mediumImpact();
    return true;
  }

  /// Manually trigger shot (e.g. for testing or tap simulation)
  bool registerManualShot({double? customTimeSec}) {
    if (!_isRunning) return false;
    final now = _clock();
    final elapsedSec = customTimeSec ??
        (_startBeepTime != null
            ? (now.difference(_startBeepTime!).inMicroseconds / 1000000.0)
            : 0.0);

    if (_recordedShots.isNotEmpty) {
      final last = _recordedShots.last;
      if (elapsedSec - last.cumulativeTimeSec < minSplitLockoutSec) {
        return false;
      }
    }

    final double split = _recordedShots.isEmpty
        ? elapsedSec
        : elapsedSec - _recordedShots.last.cumulativeTimeSec;

    _recordedShots.add(
      ShotRecord(
        stringId: 0,
        shotNumber: _recordedShots.length + 1,
        splitTimeSec: double.parse(split.toStringAsFixed(2)),
        cumulativeTimeSec: double.parse(elapsedSec.toStringAsFixed(2)),
      ),
    );
    return true;
  }

  /// Delete errant shot by index
  void deleteShot(int index) {
    if (index >= 0 && index < _recordedShots.length) {
      _recordedShots.removeAt(index);
      // Re-number remaining shots
      for (int i = 0; i < _recordedShots.length; i++) {
        final current = _recordedShots[i];
        final prevCumul = i == 0 ? 0.0 : _recordedShots[i - 1].cumulativeTimeSec;
        final split = current.cumulativeTimeSec - prevCumul;
        _recordedShots[i] = ShotRecord(
          id: current.id,
          stringId: current.stringId,
          shotNumber: i + 1,
          splitTimeSec: double.parse(split.toStringAsFixed(2)),
          cumulativeTimeSec: current.cumulativeTimeSec,
        );
      }
    }
  }

  void stopSession() {
    _randomDelayTimer?.cancel();
    _isArmed = false;
    _isRunning = false;
  }
}
