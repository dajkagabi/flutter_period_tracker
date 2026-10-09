import 'package:flutter/foundation.dart';
import 'package:flutter_period_tracker/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AppSettings {
  const AppSettings({
    this.periodReminderEnabled = true,
    this.daysBefore = 2,
  });

  final bool periodReminderEnabled;
  final int daysBefore;

  AppSettings copyWith({bool? periodReminderEnabled, int? daysBefore}) =>
      AppSettings(
        periodReminderEnabled:
            periodReminderEnabled ?? this.periodReminderEnabled,
        daysBefore: daysBefore ?? this.daysBefore,
      );
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _enabledKey = 'period_reminder_enabled';
  static const _daysKey = 'period_reminder_days_before';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      periodReminderEnabled: prefs.getBool(_enabledKey) ?? true,
      daysBefore: prefs.getInt(_daysKey) ?? 2,
    );
  }

  Future<void> setPeriodReminderEnabled(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (value) await ref.read(notificationServiceProvider).requestPermission();
    await prefs.setBool(_enabledKey, value);
    state = state.copyWith(periodReminderEnabled: value);
  }

  Future<void> setDaysBefore(int days) async {
    await ref.read(sharedPreferencesProvider).setInt(_daysKey, days);
    state = state.copyWith(daysBefore: days);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
