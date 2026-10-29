import 'dart:math' as math;

/// Fast RMS (Root Mean Square) energy envelope calculation for PCM audio blocks.
class RmsCalculator {
  RmsCalculator._();

  /// Calculates root-mean-square amplitude across [samples].
  static double rms(List<double> samples) {
    if (samples.isEmpty) return 0.0;
    var sum = 0.0;
    for (var i = 0; i < samples.length; i++) {
      final s = samples[i];
      sum += s * s;
    }
    return math.sqrt(sum / samples.length);
  }
}
