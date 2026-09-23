import 'package:sqflite/sqflite.dart';

import '../../../core/database/local_database.dart';
import 'daily_log_model.dart';

class DailyLogRepository {
  final LocalDatabase _dbProvider = LocalDatabase.instance;

  // Napi adat mentése vagy frissítése (Insert/Update)
  Future<void> saveDailyLog(DailyLog log) async {
    final db = await _dbProvider.database;

    // Ha arra a napra már létezik bejegyzés, felülírja (ConflictAlgorithm.replace)
    await db.insert(
      'daily_logs',
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Egy konkrét nap adatainak lekérése
  Future<DailyLog?> getLogByDate(DateTime date) async {
    final db = await _dbProvider.database;
    final dateStr = date.toIso8601String().split('T')[0];

    final maps = await db.query(
      'daily_logs',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (maps.isNotEmpty) {
      return DailyLog.fromMap(maps.first);
    }
    return null;
  }

  // Egy adott időszak (pl. egy hónap) adatainak lekérése a naptárhoz
  Future<List<DailyLog>> getLogsForRange(DateTime start, DateTime end) async {
    final db = await _dbProvider.database;
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    final maps = await db.query(
      'daily_logs',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startStr, endStr],
    );

    return maps.map((map) => DailyLog.fromMap(map)).toList();
  }
}
