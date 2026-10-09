import 'dart:convert';

import 'package:flutter_period_tracker/core/database/app_database.dart';
import 'package:flutter_period_tracker/core/utils/date_utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../domain/daily_log.dart';
import 'daily_log_repository.dart';

class SqliteDailyLogRepository implements DailyLogRepository {
  SqliteDailyLogRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();
  static const _table = 'daily_logs';

  @override
  Future<DailyLog?> getByDate(DateTime date) async {
    final db = await _db.database;
    final rows = await db.query(
      _table,
      where: 'date = ? AND deleted_at IS NULL',
      whereArgs: [dayKey(date)],
      limit: 1,
    );
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<List<DailyLog>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(
      _table,
      where: 'deleted_at IS NULL',
      orderBy: 'date ASC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<DailyLog>> getRange(DateTime start, DateTime end) async {
    final db = await _db.database;
    final rows = await db.query(
      _table,
      where: 'date BETWEEN ? AND ? AND deleted_at IS NULL',
      whereArgs: [dayKey(start), dayKey(end)],
      orderBy: 'date ASC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> save(DailyLog log) async {
    final db = await _db.database;
    final key = dayKey(log.date);
    final now = DateTime.now().toUtc().toIso8601String();

    // Upsert tranzakcióban: a meglévő sor azonosítója megmarad
    // (szinkronizációhoz stabil azonosító kell), és a törölt sor is feléled.
    await db.transaction((txn) async {
      final existing = await txn.query(
        _table,
        columns: ['id'],
        where: 'date = ?',
        whereArgs: [key],
        limit: 1,
      );
      final values = _toRow(log)
        ..['updated_at'] = now
        ..['deleted_at'] = null;

      if (existing.isEmpty) {
        await txn.insert(_table, {
          ...values,
          'id': _uuid.v4(),
          'date': key,
          'created_at': now,
        });
      } else {
        await txn.update(_table, values, where: 'date = ?', whereArgs: [key]);
      }
    });
  }

  @override
  Future<void> delete(DateTime date) async {
    final db = await _db.database;
    final now = DateTime.now().toUtc().toIso8601String();
    // Soft delete: a későbbi szinkronizáció tudni fogja, hogy törölve lett.
    await db.update(
      _table,
      {'deleted_at': now, 'updated_at': now},
      where: 'date = ? AND deleted_at IS NULL',
      whereArgs: [dayKey(date)],
    );
  }

  // ---------------------------------------------------------------------------

  Map<String, Object?> _toRow(DailyLog log) => {
        'is_period_start': log.isPeriodStart ? 1 : 0,
        'is_period_end': log.isPeriodEnd ? 1 : 0,
        'flow': log.flow?.name,
        'moods': _encode(log.moods),
        'physical_symptoms': _encode(log.physicalSymptoms),
        'skin_symptoms': _encode(log.skinSymptoms),
        'other_symptoms': _encode(log.otherSymptoms),
        'had_sexual_activity': log.hadSexualActivity ? 1 : 0,
        'protection': log.protection?.name,
        'cervical_mucus': log.cervicalMucus?.name,
      };

  DailyLog _fromRow(Map<String, Object?> row) => DailyLog(
        date: parseDayKey(row['date']! as String),
        isPeriodStart: row['is_period_start'] == 1,
        isPeriodEnd: row['is_period_end'] == 1,
        flow: _enumOrNull(FlowIntensity.values, row['flow']),
        moods: _decode(Mood.values, row['moods']),
        physicalSymptoms: _decode(PhysicalSymptom.values, row['physical_symptoms']),
        skinSymptoms: _decode(SkinSymptom.values, row['skin_symptoms']),
        otherSymptoms: _decode(OtherSymptom.values, row['other_symptoms']),
        hadSexualActivity: row['had_sexual_activity'] == 1,
        protection: _enumOrNull(ProtectionType.values, row['protection']),
        cervicalMucus: _enumOrNull(CervicalMucus.values, row['cervical_mucus']),
      );

  String _encode(Set<Enum> values) =>
      jsonEncode(values.map((e) => e.name).toList());

  Set<T> _decode<T extends Enum>(List<T> values, Object? raw) {
    if (raw is! String || raw.isEmpty) return <T>{};
    final byName = values.asNameMap();
    final result = <T>{};
    for (final name in jsonDecode(raw) as List) {
      final value = byName[name];
      if (value != null) result.add(value);
    }
    return result;
  }

  T? _enumOrNull<T extends Enum>(List<T> values, Object? raw) =>
      raw is String ? values.asNameMap()[raw] : null;
}
