import '../domain/reminder.dart';

abstract interface class ReminderRepository {
  Future<List<Reminder>> getAll();

  /// Elmenti és visszaadja az azonosítóval ellátott emlékeztetőt.
  Future<Reminder> add(Reminder reminder);
  Future<void> setEnabled(int id, bool enabled);
  Future<void> delete(int id);
}
