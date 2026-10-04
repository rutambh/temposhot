/// Tracks the ambient noise level of the room so detection can use a
/// *relative* threshold instead of a fixed one.
///
/// Only samples that fall below the current detection threshold are fed into
/// the floor. That keeps a gunshot from dragging the floor up behind itself
/// and blinding the detector for the rest of the string.
class NoiseFloorEstimator {
  /// How far above the measured floor a sample must sit to count as a shot.
  final double sensitivityMargin;

  /// Smoothing factor for the floor. Lower = slower to adapt, quieter room.
  final double smoothing;

  double _noiseFloor = 0.0;
  bool _primed = false;

  NoiseFloorEstimator({
    this.sensitivityMargin = 0.18,
    this.smoothing = 0.2,
  })  : assert(sensitivityMargin >= 0),
        assert(smoothing > 0 && smoothing <= 1);

  /// Current estimate of the ambient noise level, 0.0 - 1.0.
  double get noiseFloor => _noiseFloor;

  /// Amplitude a sample must reach to be treated as a shot.
  double get threshold => (_noiseFloor + sensitivityMargin).clamp(0.0, 1.0);

  /// Feed one amplitude sample. Samples at or above [threshold] are ignored so
  /// they cannot pollute the floor.
  void addSample(double amplitude) {
    // Seed from the first sample seen. Without this the estimator could never
    // bootstrap in a room louder than the initial threshold, because every
    // sample would be discarded as a "shot".
    if (!_primed) {
      _noiseFloor = amplitude;
      _primed = true;
      return;
    }
    if (amplitude >= threshold) return;
    _noiseFloor = _noiseFloor * (1 - smoothing) + amplitude * smoothing;
  }

  void reset() {
    _noiseFloor = 0.0;
    _primed = false;
  }
}
