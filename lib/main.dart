import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/app.dart';
import 'package:flutter_period_tracker/core/providers.dart';
import 'package:flutter_period_tracker/core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('hu_HU');

  final prefs = await SharedPreferences.getInstance();

  // Az értesítések hibája nem akadályozhatja az app indulását.
  final notifications = NotificationService();
  try {
    await notifications.init();
  } catch (e, st) {
    debugPrint('Az értesítési szolgáltatás indítása sikertelen: $e\n$st');
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const PeriodTrackerApp(),
    ),
  );
}
