import '../domain/daily_log.dart';

/// A napló tárolásának absztrakciója.
/// Most SQLite, később távoli / szinkronizált adatbázis is megvalósíthatja.
abstract interface class DailyLogRepository {
  Future<DailyLog?> getByDate(DateTime date);
  Future<List<DailyLog>> getAll();
  Future<List<DailyLog>> getRange(DateTime start, DateTime end);

  /// Létrehozza vagy frissíti az adott napi bejegyzést.
  Future<void> save(DailyLog log);

  /// Törli az adott napi bejegyzést (ha van).
  Future<void> delete(DateTime date);
}
