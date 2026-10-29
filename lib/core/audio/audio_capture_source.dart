import 'dart:async';
import 'dart:math' as math;
import '../../features/live_timer/domain/rms_calculator.dart';

/// Single captured audio sample with normalized amplitude (0.0 to 1.0).
class AudioSample {
  final double amplitude;
  final DateTime capturedAt;

  const AudioSample({required this.amplitude, required this.capturedAt});
}

/// Abstract contract for acoustic microphone capture.
abstract class AudioCaptureSource {
  bool get isAvailable;
  String? get unavailableReason;
  bool get isCapturing;
  Stream<AudioSample> get samples;

  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
}

/// Converts raw PCM samples to a normalized amplitude [AudioSample].
AudioSample sampleFromPcm(
  List<double> pcm, {
  DateTime? capturedAt,
  double fullScale = 32768.0,
}) {
  final peak = pcm.isEmpty
      ? 0.0
      : pcm.map((s) => s.abs()).reduce(math.max) / fullScale;
  final rms = RmsCalculator.rms(pcm) / fullScale;
  return AudioSample(
    amplitude: rms.clamp(0.0, 1.0) > peak
        ? rms.clamp(0.0, 1.0)
        : peak.clamp(0.0, 1.0),
    capturedAt: capturedAt ?? DateTime.now(),
  );
}

/// Returned when microphone permission is denied or no device exists.
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

/// Deterministic simulated capture source for headless tests and web previews.
class SimulatedAudioCaptureSource implements AudioCaptureSource {
  final Duration interval;
  final double ambientLevel;
  int _tick = 0;

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
      if (_timer == null || _disposed) return;
      _tick++;
      final wobble = (_tick % 7) * 0.002;
      _controller.add(AudioSample(
        amplitude: (ambientLevel + wobble).clamp(0.0, 1.0),
        capturedAt: DateTime.now(),
      ));
    });
  }

  @override
  Future<void> stop() async {
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
