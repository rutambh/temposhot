import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/audio_capture_source.dart';
import '../../data/datasources/microphone_audio_capture_source.dart';
import '../../data/datasources/temposhot_database.dart';
import '../../domain/engine/shot_detection_engine.dart';
import '../../domain/models/drill.dart';
import '../../domain/models/shot_string.dart';

final tempoDatabaseProvider = Provider<TempoShotDatabase>((ref) {
  return TempoShotDatabase.instance;
});

final allStringsProvider = FutureProvider<List<ShotString>>((ref) async {
  final db = ref.watch(tempoDatabaseProvider);
  return db.getAllStrings();
});

final stringCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(tempoDatabaseProvider);
  return db.getStringCount();
});

final allDrillsProvider = FutureProvider<List<Drill>>((ref) async {
  final db = ref.watch(tempoDatabaseProvider);
  return db.getAllDrills();
});

/// The one owner of microphone capture for the live timer.
///
/// autoDispose ties the microphone to whichever screen is watching it: when
/// the live timer goes away Riverpod runs the disposer and the hardware is
/// released, so no audio stream can outlive the screen that opened it.
final audioCaptureSourceProvider = Provider.autoDispose<AudioCaptureSource>((ref) {
  final source = MicrophoneAudioCaptureSource(RecordPluginRecorder());
  ref.onDispose(source.dispose);
  return source;
});

/// Session-scoped: a new live timer must never inherit the previous
/// session's shots.
final shotEngineProvider = Provider.autoDispose<ShotDetectionEngine>((ref) {
  return ShotDetectionEngine();
});
