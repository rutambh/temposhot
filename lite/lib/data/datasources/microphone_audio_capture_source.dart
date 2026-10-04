import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

import 'audio_capture_source.dart';

/// The seam over the capture plugin.
///
/// Detection code talks to this, never to the plugin, so the microphone can be
/// swapped for a synthetic source (tests, platforms without capture) without
/// touching the detector.
abstract class MicrophoneRecorder {
  /// Asks the user for microphone access. Returns false if refused.
  Future<bool> requestPermission();

  /// Begins streaming raw mono PCM blocks, normalised to -1.0 - 1.0.
  Future<Stream<List<double>>> startPcmStream();

  Future<void> stop();

  Future<void> dispose();
}

/// Real microphone capture, backed by the `record` plugin.
///
/// 16-bit mono PCM at 44.1 kHz. Blocks are small enough that a gunshot is
/// captured across several blocks rather than being smoothed away.
class RecordPluginRecorder implements MicrophoneRecorder {
  RecordPluginRecorder({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  static const _sampleRate = 44100;
  static const _pcmFullScale = 32768.0;

  @override
  Future<bool> requestPermission() => _recorder.hasPermission();

  @override
  Future<Stream<List<double>>> startPcmStream() async {
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
      ),
    );
    return stream.map(_toDoubles);
  }

  @override
  Future<void> stop() async => _recorder.stop();

  @override
  Future<void> dispose() => _recorder.dispose();

  /// Little-endian signed 16-bit samples to normalised doubles.
  static List<double> _toDoubles(Uint8List bytes) {
    final view = ByteData.sublistView(bytes);
    final samples = <double>[];
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      samples.add(view.getInt16(i, Endian.little) / _pcmFullScale);
    }
    return samples;
  }
}

/// Microphone-backed [AudioCaptureSource].
///
/// If permission is refused the source stays available=false with a reason,
/// and emits nothing, rather than throwing or pretending to detect shots.
class MicrophoneAudioCaptureSource implements AudioCaptureSource {
  MicrophoneAudioCaptureSource(this._recorder);

  final MicrophoneRecorder _recorder;

  StreamController<AudioSample>? _out;
  StreamSubscription<List<double>>? _subscription;
  String? _unavailableReason;

  @override
  bool get isAvailable => _unavailableReason == null;

  @override
  String? get unavailableReason => _unavailableReason;

  @override
  bool get isCapturing => _subscription != null;

  @override
  Stream<AudioSample> get samples =>
      _out?.stream ?? const Stream<AudioSample>.empty();

  @override
  Future<void> start() async {
    if (isCapturing) return;

    final granted = await _recorder.requestPermission();
    if (!granted) {
      _unavailableReason = 'Microphone permission was not granted.';
      return;
    }

    // Broadcast: a live capture stream has no late-subscriber buffering
    // requirement, and its close() completes even if nothing ever listened.
    // A single-subscription close() would hang teardown forever.
    final controller = StreamController<AudioSample>.broadcast();
    _out = controller;
    final pcm = await _recorder.startPcmStream();
    _subscription = pcm.listen(
      (block) => controller.add(sampleFromPcm(block)),
      onError: (Object error) {
        _unavailableReason = 'Microphone capture failed: $error';
      },
      onDone: () => controller.close(),
    );
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _out?.close();
    _out = null;
    await _recorder.stop();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _recorder.dispose();
  }
}
