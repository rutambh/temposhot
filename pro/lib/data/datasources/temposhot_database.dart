import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/drill.dart';
import '../../domain/models/shot_record.dart';
import '../../domain/models/shot_string.dart';

class TempoShotDatabase {
  static final TempoShotDatabase instance = TempoShotDatabase._init();
  static Database? _database;

  TempoShotDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('temposhot.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE drills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        targetParTimeSec REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE strings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        drillId INTEGER NOT NULL,
        shooterId INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        totalTimeSec REAL NOT NULL,
        firstShotDelaySec REAL NOT NULL,
        notes TEXT NOT NULL,
        FOREIGN KEY (drillId) REFERENCES drills (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE shots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stringId INTEGER NOT NULL,
        shotNumber INTEGER NOT NULL,
        splitTimeSec REAL NOT NULL,
        cumulativeTimeSec REAL NOT NULL,
        FOREIGN KEY (stringId) REFERENCES strings (id) ON DELETE CASCADE
      )
    ''');

    // Seed standard initial drill
    await db.insert('drills', {
      'name': 'Bill Drill (6 Shots)',
      'description': 'Draw and fire 6 shots at 7 yards into A-zone.',
      'targetParTimeSec': 2.50,
    });
  }

  Future<int> insertStringWithShots(ShotString shotString, List<ShotRecord> shots) async {
    final db = await instance.database;
    final count = await getStringCount();

    // Lite paywall gating: max 10 strings stored
    if (count >= AppConstants.liteMaxStrings) {
      final oldest = await db.query('strings', orderBy: 'id ASC', limit: 1);
      if (oldest.isNotEmpty) {
        final oldestId = oldest.first['id'] as int;
        await deleteString(oldestId);
      }
    }

    final stringId = await db.insert('strings', shotString.toMap());
    for (final s in shots) {
      final shotMap = s.toMap();
      shotMap['stringId'] = stringId;
      await db.insert('shots', shotMap);
    }
    return stringId;
  }

  Future<List<ShotString>> getAllStrings() async {
    final db = await instance.database;
    final result = await db.query('strings', orderBy: 'id DESC');
    return result.map((json) => ShotString.fromMap(json)).toList();
  }

  Future<List<ShotRecord>> getShotsForString(int stringId) async {
    final db = await instance.database;
    final result = await db.query(
      'shots',
      where: 'stringId = ?',
      whereArgs: [stringId],
      orderBy: 'shotNumber ASC',
    );
    return result.map((json) => ShotRecord.fromMap(json)).toList();
  }

  Future<int> getStringCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM strings');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> deleteString(int id) async {
    final db = await instance.database;
    await db.delete('shots', where: 'stringId = ?', whereArgs: [id]);
    return await db.delete('strings', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Drill>> getAllDrills() async {
    final db = await instance.database;
    final result = await db.query('drills', orderBy: 'id ASC');
    return result.map((json) => Drill.fromMap(json)).toList();
  }
}
