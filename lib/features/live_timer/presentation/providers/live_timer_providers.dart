import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/audio/audio_capture_source.dart';
import '../../../../core/audio/microphone_audio_capture_source.dart';
import '../../../../core/database/temposhot_database.dart';
import '../../domain/shot_detection_engine.dart';

/// Database provider for reading and writing strings.
final databaseProvider = Provider<TempoShotDatabase>((ref) {
  return TempoShotDatabase.instance;
});

/// Owns the active audio capture source.
/// Disposed automatically by Riverpod when the timer screen unmounts.
final audioCaptureSourceProvider =
    Provider.autoDispose<AudioCaptureSource>((ref) {
  final source = MicrophoneAudioCaptureSource(RecordPluginRecorder());
  ref.onDispose(() {
    source.dispose();
  });
  return source;
});

/// Owns the active shot detection engine for this session.
final shotEngineProvider =
    Provider.autoDispose<ShotDetectionEngine>((ref) {
  final engine = ShotDetectionEngine();
  ref.onDispose(() {
    engine.stopSession();
  });
  return engine;
});
