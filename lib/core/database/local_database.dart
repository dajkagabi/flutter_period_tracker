import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//ISAR helyett SQLITE

//Belső adatbázis (SQLITE)

//Majd ki lehet tenni külső adatbázisba
class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._init();
  static Database? _database;

  LocalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('period_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // SQLite-ban a boolean 0 vagy 1
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const boolType = 'INTEGER';

    // 1. Napi bejegyzések tábla
    await db.execute('''
      CREATE TABLE daily_logs (
        id $idType,
        date $textType NOT NULL UNIQUE,
        isPeriodStart $boolType DEFAULT 0,
        isPeriodEnd $boolType DEFAULT 0,
        flowIntensity $textType,
        moods $textType,
        physicalSymptoms $textType,
        skinSymptoms $textType,
        otherSymptoms $textType,
        hadSexualActivity $boolType DEFAULT 0,
        protectionType $textType,
        cervicalMucus $textType
      )
    ''');

    // 2. Ciklus előzmények tábla ( Kiszámított ciklusok)
    await db.execute('''
      CREATE TABLE cycle_history (
        id $idType,
        startDate $textType NOT NULL,
        endDate $textType,
        cycleLengthDays INTEGER,
        periodLengthDays INTEGER
      )
    ''');

    // 3. Emlékeztetők tábla
    await db.execute('''
      CREATE TABLE reminders (
        id $idType,
        type $textType NOT NULL,
        title $textType NOT NULL,
        time $textType,
        intervalHours INTEGER,
        isEnabled $boolType DEFAULT 1
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
