import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A helyi SQLite adatbázis egyetlen belépési pontja.
///
/// A titkosítás bekapcsolásához elegendő ebben a fájlban az `sqflite` importot
/// `sqflite_sqlcipher`-re cserélni és az `openDatabase`-nek `password`-öt adni
/// (a kulcsot `flutter_secure_storage`-ban érdemes tárolni). Lásd README.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const _fileName = 'period_tracker.db';
  static const _version = 2;

  Future<Database>? _opening;

  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      join(dir, _fileName),
      version: _version,
      onCreate: (db, _) => _createSchema(db),
      onUpgrade: _upgrade,
    );
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE daily_logs (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        is_period_start INTEGER NOT NULL DEFAULT 0,
        is_period_end INTEGER NOT NULL DEFAULT 0,
        flow TEXT,
        moods TEXT NOT NULL DEFAULT '[]',
        physical_symptoms TEXT NOT NULL DEFAULT '[]',
        skin_symptoms TEXT NOT NULL DEFAULT '[]',
        other_symptoms TEXT NOT NULL DEFAULT '[]',
        had_sexual_activity INTEGER NOT NULL DEFAULT 0,
        protection TEXT,
        cervical_mucus TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_daily_logs_date ON daily_logs(date)');

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    // Az 1-es séma fejlesztői verzió volt (az app még nem éles), ezért
    // egyszerűen újraépítjük. Éles adatnál ide valódi migráció kerül.
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS daily_logs');
      await db.execute('DROP TABLE IF EXISTS cycle_history');
      await db.execute('DROP TABLE IF EXISTS reminders');
      await _createSchema(db);
    }
  }

  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await (await opening).close();
  }
}
