import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/core/utils/date_utils.dart';
import 'package:flutter_period_tracker/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/presentation/screens/calendar_screen.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/presentation/screens/log_daily_data_screen.dart';
import 'package:flutter_period_tracker/features/lifestyle/presentation/screens/lifestyle_screen.dart';
import 'package:flutter_period_tracker/features/reminders/presentation/screens/hygiene_reminder_screen.dart';
import 'package:flutter_period_tracker/features/reminders/presentation/screens/medical_reminder_screen.dart';
import 'package:flutter_period_tracker/features/settings/presentation/screens/settings_screen.dart';

import 'routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.calendar => const CalendarScreen(),
      AppRoutes.log => LogDailyDataScreen(
          date: settings.arguments as DateTime? ?? currentDay(),
        ),
      AppRoutes.analytics => const AnalyticsScreen(),
      AppRoutes.settings => const SettingsScreen(),
      AppRoutes.lifestyle => LifestyleScreen(
          args: settings.arguments as LifestyleArgs? ?? const LifestyleArgs(),
        ),
      AppRoutes.medicalReminders => const MedicalReminderScreen(),
      AppRoutes.hygiene => const HygieneReminderScreen(),
      _ => const Scaffold(body: Center(child: Text('Az oldal nem található'))),
    };
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}
