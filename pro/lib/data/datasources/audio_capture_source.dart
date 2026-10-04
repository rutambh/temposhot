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
  StreamController<AudioSample>? _controller;

  SimulatedAudioCaptureSource({
    this.interval = const Duration(milliseconds: 20),
    this.ambientLevel = 0.05,
  });

  @override
  bool get isAvailable => true;

  @override
  String? get unavailableReason => null;

  @override
  bool get isCapturing => _controller != null && !_controller!.isClosed;

  @override
  Stream<AudioSample> get samples =>
      _controller?.stream ?? const Stream<AudioSample>.empty();

  @override
  Future<void> start() async {
    if (isCapturing) return;
    // Broadcast so close() completes even when nothing ever listened; a
    // single-subscription controller would hang teardown forever.
    final controller = StreamController<AudioSample>.broadcast();
    _controller = controller;
    Timer.periodic(interval, (_) {
      if (controller.isClosed) return;
      _tick++;
      // A small deterministic wobble so the floor estimator sees a realistic
      // signal rather than a perfectly flat line.
      final wobble = (_tick % 7) * 0.002;
      controller.add(AudioSample(
        amplitude: (ambientLevel + wobble).clamp(0.0, 1.0),
        capturedAt: DateTime.now(),
      ));
    });
  }

  @override
  Future<void> stop() async {
    final controller = _controller;
    _controller = null;
    await controller?.close();
  }

  @override
  Future<void> dispose() => stop();
}
