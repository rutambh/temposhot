import 'dart:async';
import 'dart:math' as math;

import '../../domain/audio/rms_calculator.dart';

/// One block of captured audio, reduced to the single number the detector needs.
class AudioSample {
  /// Normalised 0.0 - 1.0 loudness of this block.
  final double amplitude;

  /// When the block was captured.
  final DateTime capturedAt;

  const AudioSample({required this.amplitude, required this.capturedAt});
}

/// Where captured microphone energy comes from.
///
/// Kept as an interface so the detection logic never depends on a capture
/// plugin. A real microphone, a synthetic source for tests and web, and the
/// "no microphone" case are all interchangeable behind this contract.
abstract class AudioCaptureSource {
  /// Whether this source can produce audio at all on this device.
  bool get isAvailable;

  /// Why the source is unavailable, or null when it is available.
  String? get unavailableReason;

  /// Whether the source is currently capturing.
  bool get isCapturing;

  /// Stream of amplitude samples. Emits nothing while unavailable.
  Stream<AudioSample> get samples;

  Future<void> start();

  Future<void> stop();

  /// Releases the underlying device. Safe to call more than once.
  Future<void> dispose();
}

/// Shared conversion from raw PCM to a normalised RMS [AudioSample].
AudioSample sampleFromPcm(
  List<double> pcm, {
  DateTime? capturedAt,
  double fullScale = 32768.0,
}) {
  final peak = pcm.isEmpty
      ? 0.0
      : pcm.map((s) => s.abs()).reduce(math.max) / fullScale;
  final rms = RmsCalculator.rms(pcm) / fullScale;
  // Normalise by whichever is larger so a quiet-but-consistent signal is not
  // crushed to nothing, while a single full-scale spike still reads as 1.0.
  return AudioSample(
    amplitude: rms.clamp(0.0, 1.0) > peak ? rms.clamp(0.0, 1.0) : peak.clamp(0.0, 1.0),
    capturedAt: capturedAt ?? DateTime.now(),
  );
}

/// Used when the device has no microphone, or the user declined permission.
class UnavailableAudioCaptureSource implements AudioCaptureSource {
  @override
  final String? unavailableReason;

  const UnavailableAudioCaptureSource(this.unavailableReason);

  @override
  bool get isAvailable => false;

  @override
  bool get isCapturing => false;

  @override
  Stream<AudioSample> get samples => const Stream<AudioSample>.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

/// Deterministic synthetic source.
///
/// Used by tests, and as the fallback on platforms where no microphone capture
/// plugin is available. Emits a steady ambient bed so the noise floor
/// estimator has something realistic to adapt to.
class SimulatedAudioCaptureSource implements AudioCaptureSource {
  final Duration interval;
  final double ambientLevel;
  int _tick = 0;

  /// Long-lived and created eagerly, so [samples] is the same stream object
  /// before and after [start]. Building it inside start() meant a listener
  /// that subscribed first -- which is what the live timer does -- was stuck
  /// on a dead `Stream.empty()` and detected nothing.
  final StreamController<AudioSample> _controller =
      StreamController<AudioSample>.broadcast();

  Timer? _timer;
  bool _disposed = false;

  SimulatedAudioCaptureSource({
    this.interval = const Duration(milliseconds: 20),
    this.ambientLevel = 0.05,
  });

  @override
  bool get isAvailable => true;

  @override
  String? get unavailableReason => null;

  @override
  bool get isCapturing => _timer != null;

  @override
  Stream<AudioSample> get samples => _controller.stream;

  @override
  Future<void> start() async {
    if (isCapturing || _disposed) return;
    _timer = Timer.periodic(interval, (_) {
      _tick++;
      // A small deterministic wobble so the floor estimator sees a realistic
      // signal rather than a perfectly flat line.
      final wobble = (_tick % 7) * 0.002;
      _controller.add(AudioSample(
        amplitude: (ambientLevel + wobble).clamp(0.0, 1.0),
        capturedAt: DateTime.now(),
      ));
    });
  }

  @override
  Future<void> stop() async {
    // The sampler must stop with the source. Leaving the periodic timer alive
    // keeps a 20ms tick running for the life of the process after the screen
    // that owned it is gone.
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stop();
    await _controller.close();
  }
}
