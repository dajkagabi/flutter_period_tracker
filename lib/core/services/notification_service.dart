import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_period_tracker/core/utils/date_utils.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Értesítés-azonosítók. Külön tartományok, hogy a típusok ne ütközzenek.
abstract final class NotificationIds {
  static const int periodReminder = 1;
  static const int hygieneTimer = 2;
  static int medical(int reminderId) => 1000 + reminderId;
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _periodChannel = ('period_reminder', 'Ciklus emlékeztető');
  static const _hygieneChannel = ('hygiene_reminder', 'Higiéniai emlékeztető');
  static const _medicalChannel = ('medical_reminder', 'Napi emlékeztetők');

  Future<void> init() async {
    tz_data.initializeTimeZones();
    // Az eszköz időzónája nélkül a tz.local UTC lenne, és minden
    // időzített értesítés elcsúszna.
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Europe/Budapest'));
    }

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  /// Engedélykérés – akkor hívjuk, amikor a felhasználó értesítést kapcsol be.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: false,
      sound: true,
    );
    return androidGranted ?? iosGranted ?? true;
  }

  /// Figyelem: a tartalom érzékeny, ezért zárolt képernyőn nem jelenik meg.
  NotificationDetails _details((String, String) channel) => NotificationDetails(
        android: AndroidNotificationDetails(
          channel.$1,
          channel.$2,
          importance: Importance.high,
          priority: Priority.high,
          visibility: NotificationVisibility.private,
        ),
        iOS: const DarwinNotificationDetails(),
      );

  /// A várható menstruáció előtti emlékeztető (reggel 9:00).
  /// `false`-t ad vissza, ha az időpont már elmúlt.
  Future<bool> schedulePeriodReminder({
    required DateTime periodStart,
    required int daysBefore,
  }) async {
    final day = addDays(periodStart, -daysBefore);
    final when = tz.TZDateTime(tz.local, day.year, day.month, day.day, 9);
    if (!when.isAfter(tz.TZDateTime.now(tz.local))) return false;

    final body = daysBefore == 1
        ? 'A becslés szerint holnap kezdődik a következő ciklusod.'
        : 'A becslés szerint $daysBefore nap múlva kezdődik a következő ciklusod.';

    await _plugin.zonedSchedule(
      NotificationIds.periodReminder,
      'Cikluskövető',
      body,
      when,
      _details(_periodChannel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return true;
  }

  /// Napi ismétlődő emlékeztető (gyógyszer, vitamin).
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var when =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!when.isAfter(now)) when = when.add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      _details(_medicalChannel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Egyszeri értesítés adott időpontra (higiéniai időzítő lejárata).
  Future<void> scheduleOnce({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(at, tz.local),
      _details(_hygieneChannel),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}
