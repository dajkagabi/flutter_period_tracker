import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton minta: csak egy példány létezik az alkalmazásban
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Értesítési rendszer inicializálása
  Future<void> init() async {
    // Időzónák inicializálása az időzített értesítésekhez
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Engedély kérése Android 13+ eszközökön
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // Értesítés beidőzítése a várható menstruáció előtt X nappal
  Future<void> schedulePeriodReminder({
    required DateTime nextPeriodDate,
    int daysBefore = 2,
  }) async {
    // Töröljük a korábbi időzítéseket, hogy ne legyenek duplikációk
    await cancelAllNotifications();

    // Kiszámoljuk az értesítés pontos idejét (X nappal előtte, reggel 9:00-kor)
    final notificationDate = nextPeriodDate.subtract(
      Duration(days: daysBefore),
    );
    final scheduledDate = tz.TZDateTime(
      tz.local,
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      9,
      0,
    );

    // Csak akkor időzítjük be, ha a dátum a jövőben van
    if (scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'period_reminder_channel',
            'Menstruációs emlékeztető',
            channelDescription: 'Emlékeztető a várható menstruáció előtt',
            importance: Importance.max,
            priority: Priority.high,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Értesítés azonosítója (ID)
        'Közeleg a menstruációd! ',
        'A számítások szerint kb. $daysBefore nap múlva várható a következő ciklusod.',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Összes beidőzített értesítés törlése
  // 1. ne legyen duplikálás.
  // 2. a ciklushossz változik
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
