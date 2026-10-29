import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/temposhot_database.dart';
import '../../domain/models/shot_string.dart';

final historyDatabaseProvider = Provider<TempoShotDatabase>((ref) {
  return TempoShotDatabase.instance;
});

final allStringsProvider = FutureProvider<List<ShotString>>((ref) async {
  final db = ref.watch(historyDatabaseProvider);
  return db.getAllStrings();
});

final stringCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(historyDatabaseProvider);
  return db.getStringCount();
});
