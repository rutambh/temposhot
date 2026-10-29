import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../features/history/domain/models/drill.dart';
import '../../features/history/domain/models/shot_record.dart';
import '../../features/history/domain/models/shot_string.dart';
import '../config/app_flavor.dart';

/// Local SQLite database for TempoShot strings, splits, and drills.
///
/// Guaranteed zero network; all records are stored in the application sandbox.
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
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // Enforce SQLite foreign keys and cascade deletions (fixes IMP-05)
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Future schema migrations go here (fixes IMP-04)
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shooters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE drills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        targetParTimeSec REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE strings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        drillId INTEGER NOT NULL,
        shooterId INTEGER NOT NULL DEFAULT 1,
        timestamp TEXT NOT NULL,
        totalTimeSec REAL NOT NULL,
        firstShotDelaySec REAL NOT NULL,
        notes TEXT,
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

    // Default standard starter drill
    await db.insert('drills', {
      'name': 'Bill Drill (6 Shots)',
      'description': 'Draw and fire 6 shots at 7 yards into A-zone.',
      'targetParTimeSec': 2.50,
    });
  }

  /// Insert a new string and all associated shot splits.
  ///
  /// If [autoEvictOldest] is true and the Lite edition 10-string limit is reached,
  /// the oldest string will be replaced.
  Future<int> insertStringWithShots(
    ShotString shotString,
    List<ShotRecord> shots, {
    bool autoEvictOldest = true,
  }) async {
    final db = await instance.database;
    final maxLimit = AppFlavorConfig.current.maxSavedStrings;

    if (maxLimit != null) {
      final count = await getStringCount();
      if (count >= maxLimit && autoEvictOldest) {
        final oldest = await db.query('strings', orderBy: 'id ASC', limit: 1);
        if (oldest.isNotEmpty) {
          final oldestId = oldest.first['id'] as int;
          await deleteString(oldestId);
        }
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
    final res = await db.rawQuery('SELECT COUNT(*) as cnt FROM strings');
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<List<Drill>> getAllDrills() async {
    final db = await instance.database;
    final result = await db.query('drills', orderBy: 'id ASC');
    return result.map((json) => Drill.fromMap(json)).toList();
  }

  Future<int> insertDrill(Drill drill) async {
    final db = await instance.database;
    return await db.insert('drills', drill.toMap());
  }

  Future<int> deleteString(int id) async {
    final db = await instance.database;
    // Foreign keys with CASCADE will remove associated shots automatically
    return await db.delete('strings', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('shots');
    await db.delete('strings');
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
