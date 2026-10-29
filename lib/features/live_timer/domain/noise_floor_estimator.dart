/// Tracks the ambient background noise floor so detection can adapt dynamically.
class NoiseFloorEstimator {
  final double sensitivityMargin;
  final double smoothing;

  double _noiseFloor = 0.0;
  bool _primed = false;

  NoiseFloorEstimator({
    this.sensitivityMargin = 0.18,
    this.smoothing = 0.2,
  })  : assert(sensitivityMargin >= 0),
        assert(smoothing > 0 && smoothing <= 1);

  double get noiseFloor => _noiseFloor;
  double get threshold => (_noiseFloor + sensitivityMargin).clamp(0.0, 1.0);

  void addSample(double amplitude) {
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
