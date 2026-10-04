import 'dart:math' as math;

/// Root-mean-square of a block of PCM samples, normalised to 0.0 - 1.0.
///
/// RMS is used instead of peak amplitude because a gunshot is a short burst:
/// its peak is brief and jittery, whereas its energy over a block is stable
/// enough to threshold reliably.
class RmsCalculator {
  RmsCalculator._();

  static double rms(List<double> samples) {
    if (samples.isEmpty) return 0.0;
    var sumOfSquares = 0.0;
    for (final s in samples) {
      sumOfSquares += s * s;
    }
    return math.sqrt(sumOfSquares / samples.length);
  }
}
