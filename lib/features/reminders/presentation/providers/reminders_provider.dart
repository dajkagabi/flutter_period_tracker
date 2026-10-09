import 'package:flutter/foundation.dart';
import 'package:flutter_period_tracker/core/providers.dart';
import 'package:flutter_period_tracker/core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reminder_repository.dart';
import '../../data/sqlite_reminder_repository.dart';
import '../../domain/reminder.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => SqliteReminderRepository(ref.watch(appDatabaseProvider)),
);

class RemindersNotifier extends AsyncNotifier<List<Reminder>> {
  ReminderRepository get _repo => ref.read(reminderRepositoryProvider);
  NotificationService get _notifications =>
      ref.read(notificationServiceProvider);

  @override
  Future<List<Reminder>> build() async {
    final reminders = await ref.watch(reminderRepositoryProvider).getAll();
    // Indításkor újraütemezünk (időzóna-váltás, törölt ütemezés ellen).
    for (final r in reminders) {
      if (r.enabled) await _schedule(r);
    }
    return reminders;
  }

  Future<void> add(Reminder reminder) async {
    await _notifications.requestPermission();
    final saved = await _repo.add(reminder);
    await _schedule(saved);
    state = AsyncData(await _repo.getAll());
  }

  Future<void> setEnabled(Reminder reminder, bool enabled) async {
    final id = reminder.id!;
    await _repo.setEnabled(id, enabled);
    if (enabled) {
      await _notifications.requestPermission();
      await _schedule(reminder.copyWith(enabled: true));
    } else {
      await _notifications.cancel(NotificationIds.medical(id));
    }
    state = AsyncData(await _repo.getAll());
  }

  Future<void> remove(Reminder reminder) async {
    final id = reminder.id!;
    await _notifications.cancel(NotificationIds.medical(id));
    await _repo.delete(id);
    state = AsyncData(await _repo.getAll());
  }

  Future<void> _schedule(Reminder r) async {
    try {
      await _notifications.scheduleDaily(
        id: NotificationIds.medical(r.id!),
        title: 'Emlékeztető',
        body: 'Ideje: ${r.title}',
        hour: r.hour,
        minute: r.minute,
      );
    } catch (e, st) {
      debugPrint('Emlékeztető ütemezése sikertelen: $e\n$st');
    }
  }
}

final remindersProvider =
    AsyncNotifierProvider<RemindersNotifier, List<Reminder>>(
  RemindersNotifier.new,
);
