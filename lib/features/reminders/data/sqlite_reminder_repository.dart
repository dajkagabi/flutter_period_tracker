import 'package:flutter_period_tracker/core/database/app_database.dart';

import '../domain/reminder.dart';
import 'reminder_repository.dart';

class SqliteReminderRepository implements ReminderRepository {
  SqliteReminderRepository(this._db);

  final AppDatabase _db;
  static const _table = 'reminders';

  @override
  Future<List<Reminder>> getAll() async {
    final db = await _db.database;
    final rows = await db.query(_table, orderBy: 'hour ASC, minute ASC');
    return rows
        .map(
          (r) => Reminder(
            id: r['id']! as int,
            type: ReminderType.values.asNameMap()[r['type']] ??
                ReminderType.medication,
            title: r['title']! as String,
            hour: r['hour']! as int,
            minute: r['minute']! as int,
            enabled: r['enabled'] == 1,
          ),
        )
        .toList();
  }

  @override
  Future<Reminder> add(Reminder reminder) async {
    final db = await _db.database;
    final id = await db.insert(_table, {
      'type': reminder.type.name,
      'title': reminder.title,
      'hour': reminder.hour,
      'minute': reminder.minute,
      'enabled': reminder.enabled ? 1 : 0,
    });
    return reminder.copyWith(id: id);
  }

  @override
  Future<void> setEnabled(int id, bool enabled) async {
    final db = await _db.database;
    await db.update(
      _table,
      {'enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
