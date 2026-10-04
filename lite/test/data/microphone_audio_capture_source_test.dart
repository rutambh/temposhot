import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:temposhot/data/datasources/microphone_audio_capture_source.dart';

/// Test double for the recorder backend. Test-only code stays here, in the
/// test tree, rather than leaking into production classes.
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
    test('reports unavailable and emits nothing when permission is denied',
        () async {
      final recorder = _FakeRecorder(permissionGranted: false);
      final source = MicrophoneAudioCaptureSource(recorder);
      addTearDown(source.dispose);

      var emitted = 0;
      final sub = source.samples.listen((_) => emitted++);

      await source.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(source.isAvailable, isFalse);
      expect(source.unavailableReason, isNotNull);
      expect(recorder.streamRequested, isFalse,
          reason: 'must not open the mic the user refused');
      expect(emitted, 0, reason: 'a refused mic must stay silent');

      await sub.cancel();
    });

    // The live timer subscribes first and calls start() second. When the
    // output stream was created inside start(), that order left the timer
    // listening to a dead Stream.empty() and it never detected a shot.
    test('a listener that subscribes before start() still receives samples',
        () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      addTearDown(source.dispose);

      final received = <double>[];
      final sub = source.samples.listen((s) => received.add(s.amplitude));

      await source.start();
      recorder.controller.add(List<double>.filled(64, 16384));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(received, isNotEmpty,
          reason: 'subscribing before start() must not silently lose audio');
      expect(received.last, closeTo(0.5, 0.01));

      await sub.cancel();
    });

    test('the PCM stream ending is reported rather than going quiet',
        () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      addTearDown(source.dispose);

      await source.start();
      await recorder.controller.close();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(source.isAvailable, isFalse,
          reason: 'capture ending mid-string must surface, not vanish');
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

    test('maps a half-scale PCM block to an amplitude of about 0.5', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      await source.start();

      final next = source.samples.first;
      recorder.controller.add(List<double>.filled(64, 16384));

      final sample = await next;
      expect(sample.amplitude, closeTo(0.5, 0.01));
    });

    test('maps silence to an amplitude of zero', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      await source.start();

      final next = source.samples.first;
      recorder.controller.add(List<double>.filled(64, 0));

      expect((await next).amplitude, 0.0);
    });

    test('stops capturing and closes the backend on stop()', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      await source.start();

      await source.stop();

      expect(source.isCapturing, isFalse);
      expect(recorder.stopped, isTrue);
    });

    test('dispose() releases the recorder', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      await source.start();

      await source.dispose();

      expect(recorder.disposed, isTrue);
      expect(source.isCapturing, isFalse);
    });

    test('dispose() twice is safe', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);
      await source.start();

      await source.dispose();
      await source.dispose();

      expect(recorder.disposed, isTrue);
    });

    test('starting twice does not open a second stream', () async {
      final recorder = _FakeRecorder(permissionGranted: true);
      final source = MicrophoneAudioCaptureSource(recorder);

      await source.start();
      await source.start();

      expect(source.isCapturing, isTrue);
      expect(recorder.controller.hasListener, isTrue);
    });
  });
}
