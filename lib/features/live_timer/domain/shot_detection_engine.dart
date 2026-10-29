import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../history/domain/models/shot_record.dart';
import 'noise_floor_estimator.dart';

/// Pure Dart acoustic shot detection and timing engine.
///
/// Decoupled from UI widgets for deterministic testing under FakeAsync.
class ShotDetectionEngine {
  double sensitivityThreshold;
  double minSplitLockoutSec;
  final NoiseFloorEstimator? noiseFloor;

  final DateTime Function() _clock;
  final math.Random _random;

  final List<ShotRecord> _recordedShots = [];
  DateTime? _startBeepTime;
  Timer? _randomDelayTimer;
  bool _isArmed = false;
  bool _isRunning = false;

  ShotDetectionEngine({
    double? sensitivityThreshold,
    double? minSplitLockoutSec,
    this.noiseFloor,
    DateTime Function()? clock,
    math.Random? random,
  })  : sensitivityThreshold = sensitivityThreshold ?? AppConstants.defaultSensitivityThreshold,
        minSplitLockoutSec = minSplitLockoutSec ?? AppConstants.minSplitLockoutSec,
        _clock = clock ?? DateTime.now,
        _random = random ?? math.Random();

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

  /// Alias for resetSession.
  void reset() => resetSession();

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

    _randomDelayTimer = Timer(
      Duration(milliseconds: (delaySeconds * 1000).round()),
      () {
        if (!_isArmed) return;
        _isArmed = false;
        _isRunning = true;
        _startBeepTime = _clock();
        try {
          HapticFeedback.heavyImpact();
        } catch (_) {}
        onStartBeep();
      },
    );
  }

  bool processAudioSample(double amplitudeNorm, {DateTime? eventTime}) {
    if (!_isRunning || _startBeepTime == null) return false;

    final now = eventTime ?? _clock();
    final elapsedSec =
        now.difference(_startBeepTime!).inMicroseconds / 1000000.0;

    if (amplitudeNorm < detectionThreshold) {
      noiseFloor?.addSample(amplitudeNorm);
      return false;
    }

    // Minimum split lockout window (150ms default) eliminates acoustic echo
    if (_recordedShots.isNotEmpty) {
      final lastShot = _recordedShots.last;
      final splitFromLast = elapsedSec - lastShot.cumulativeTimeSec;
      if (splitFromLast < minSplitLockoutSec) {
        return false;
      }
    }

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
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
    return true;
  }

  bool registerManualShot({double? customTimeSec}) {
    if (!_isRunning) {
      _isArmed = false;
      _isRunning = true;
      _startBeepTime ??= _clock();
    }
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

  void deleteShot(int index) {
    if (index >= 0 && index < _recordedShots.length) {
      _recordedShots.removeAt(index);
      for (int i = 0; i < _recordedShots.length; i++) {
        final current = _recordedShots[i];
        final prevCumul =
            i == 0 ? 0.0 : _recordedShots[i - 1].cumulativeTimeSec;
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
