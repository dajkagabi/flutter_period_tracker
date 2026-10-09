import 'package:flutter_period_tracker/core/database/app_database.dart';
import 'package:flutter_period_tracker/core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A `main()`-ben kell felülírni (override) az inicializált példánnyal.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider override hiányzik'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('notificationServiceProvider override hiányzik'),
);

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);

/// A "mai nap". Külön provider, hogy tesztben felülírható legyen.
final todayProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime.utc(now.year, now.month, now.day);
});
