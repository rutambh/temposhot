import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/core/audio/microphone_audio_capture_source.dart';

class _FakeRecorder implements MicrophoneRecorder {
  _FakeRecorder({required this.permissionGranted});

  final bool permissionGranted;
  final controller = StreamController<List<double>>();
  bool stopped = false;
  bool disposed = false;
  bool streamRequested = false;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<Stream<List<double>>> startPcmStream() async {
    streamRequested = true;
    return controller.stream;
  }

  @override
  Future<void> stop() async => stopped = true;

  @override
  Future<void> dispose() async => disposed = true;
}

void main() {
  group('MicrophoneAudioCaptureSource', () {
    test('reports unavailable and emits nothing when permission is denied', () async {
      final recorder = _FakeRecorder(permissionGranted: false);
      final source = MicrophoneAudioCaptureSource(recorder);
      addTearDown(source.dispose);

      var emitted = 0;
      final sub = source.samples.listen((_) => emitted++);

      await source.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(source.isAvailable, isFalse);
      expect(source.unavailableReason, 'Microphone permission was not granted.');
      expect(recorder.streamRequested, isFalse);
      expect(emitted, 0);

      await sub.cancel();
    });

    test('a listener that subscribes before start() still receives samples', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      addTearDown(source.dispose);

      final received = <double>[];
      final sub = source.samples.listen((s) => received.add(s.amplitude));

      await source.start();
      recorder.controller.add(List<double>.filled(64, 16384));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(received, isNotEmpty);
      expect(received.last, closeTo(0.5, 0.01));

      await sub.cancel();
    });

    test('the PCM stream ending unexpectedly marks source unavailable', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      addTearDown(source.dispose);

      await source.start();
      await recorder.controller.close();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(source.isAvailable, isFalse);
      expect(source.unavailableReason, contains('ended unexpectedly'));
    });

    test('captures and is available when permission is granted', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);

      await source.start();

      expect(source.isAvailable, isTrue);
      expect(source.unavailableReason, isNull);
      expect(source.isCapturing, isTrue);
      expect(recorder.streamRequested, isTrue);
    });

    test('maps silence to an amplitude of zero', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      await source.start();

      final next = source.samples.first;
      recorder.controller.add(List<double>.filled(64, 0.0));

      expect((await next).amplitude, 0.0);
    });

    test('stops capturing and closes backend on stop()', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      await source.start();

      await source.stop();

      expect(source.isCapturing, isFalse);
      expect(recorder.stopped, isTrue);
    });

    test('dispose() releases recorder', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      await source.start();

      await source.dispose();

      expect(recorder.disposed, isTrue);
      expect(source.isCapturing, isFalse);
    });

    test('multiple calls to start() do not open multiple streams', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);

      await source.start();
      await source.start();

      expect(source.isCapturing, isTrue);
      expect(recorder.controller.hasListener, isTrue);
    });
  });
}
