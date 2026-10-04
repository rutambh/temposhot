import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final shotEngineProvider = Provider<ShotDetectionEngine>((ref) {
  return ShotDetectionEngine();
});
