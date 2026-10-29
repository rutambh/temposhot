import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'audio_capture_source.dart';

abstract class MicrophoneRecorder {
  Future<bool> requestPermission();
  Future<Stream<List<double>>> startPcmStream();
  Future<void> stop();
  Future<void> dispose();
}

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

  static List<double> _toDoubles(Uint8List bytes) {
    final view = ByteData.sublistView(bytes);
    final samples = <double>[];
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      samples.add(view.getInt16(i, Endian.little) / _pcmFullScale);
    }
    return samples;
  }
}

class MicrophoneAudioCaptureSource implements AudioCaptureSource {
  MicrophoneAudioCaptureSource(this._recorder);

  final MicrophoneRecorder _recorder;
  final StreamController<AudioSample> _out =
      StreamController<AudioSample>.broadcast();

  StreamSubscription<List<double>>? _subscription;
  String? _unavailableReason;
  bool _disposed = false;

  @override
  bool get isAvailable => _unavailableReason == null;

  @override
  String? get unavailableReason => _unavailableReason;

  @override
  bool get isCapturing => _subscription != null;

  @override
  Stream<AudioSample> get samples => _out.stream;

  @override
  Future<void> start() async {
    if (isCapturing || _disposed) return;

    final granted = await _recorder.requestPermission();
    if (!granted) {
      _unavailableReason = 'Microphone permission was not granted.';
      return;
    }

    try {
      final pcm = await _recorder.startPcmStream();
      _subscription = pcm.listen(
        (block) => _out.add(sampleFromPcm(block)),
        onError: (Object error) {
          _unavailableReason = 'Microphone capture failed: $error';
        },
        onDone: () {
          if (!_disposed) {
            _unavailableReason = 'Microphone capture ended unexpectedly.';
          }
        },
      );
    } on Object catch (error) {
      _unavailableReason = 'Microphone capture failed: $error';
    }
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _recorder.stop();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stop();
    await _out.close();
    await _recorder.dispose();
  }
}
