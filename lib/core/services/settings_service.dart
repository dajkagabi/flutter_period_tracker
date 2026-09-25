import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _daysBeforeKey = 'days_before_period';

  // Értesítések állapota (alapértelmezetten true / bekapcsolva)
  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  // Értesítések ki/bekapcsolása
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  // Hány nappal előtte küldjön értesítést
  // alapértelmezetten 2 nap
  Future<int> getDaysBeforePeriod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_daysBeforeKey) ?? 2;
  }

  // Napok számának mentése
  Future<void> setDaysBeforePeriod(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_daysBeforeKey, days);
  }
}
