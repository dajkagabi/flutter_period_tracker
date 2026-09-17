import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _keyCycleLength = 'cycle_length';
  static const String _keyPeriodLength = 'period_length';

  Future<int> getCycleLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCycleLength) ?? 28;
  }

  Future<int> getPeriodLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyPeriodLength) ?? 5;
  }

  Future<void> saveSettings({
    required int cycleLength,
    required int periodLength,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCycleLength, cycleLength);
    await prefs.setInt(_keyPeriodLength, periodLength);
  }
}
