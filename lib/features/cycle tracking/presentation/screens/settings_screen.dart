import 'package:flutter/material.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  bool _notificationsEnabled = true;
  int _daysBefore = 2;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Beállítások betöltése mentésből
  Future<void> _loadSettings() async {
    final enabled = await _settingsService.isNotificationsEnabled();
    final days = await _settingsService.getDaysBeforePeriod();

    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _daysBefore = days;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beállítások')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Értesítések',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 12),

                // Értesítések ki/bekapcsolása Switch
                SwitchListTile(
                  title: const Text('Emlékeztető a menstruáció előtt'),
                  subtitle: const Text(
                    'Értesítés küldése a várható ciklus kezdete előtt',
                  ),
                  value: _notificationsEnabled,
                  activeThumbColor:
                      Colors.pinkAccent, // activeColor helyett activeThumbColor
                  onChanged: (value) async {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    await _settingsService.setNotificationsEnabled(value);

                    // Ha kikapcsolja, töröljük a beidőzített értesítéseket
                    if (!value) {
                      await NotificationService().cancelAllNotifications();
                    }
                  },
                ),

                const Divider(),

                // Hány nappal előtte küldjön értesítést
                if (_notificationsEnabled) ...[
                  ListTile(
                    title: const Text('Emlékeztető ideje'),
                    subtitle: Text(
                      '$_daysBefore nappal a várható menstruáció előtt',
                    ),
                    trailing: DropdownButton<int>(
                      value: _daysBefore,
                      items: const [
                        DropdownMenuItem(
                          value: 1,
                          child: Text('1 nappal előtte'),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text('2 nappal előtte'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('3 nappal előtte'),
                        ),
                        DropdownMenuItem(
                          value: 5,
                          child: Text('5 nappal előtte'),
                        ),
                      ],
                      onChanged: (newValue) async {
                        if (newValue != null) {
                          setState(() {
                            _daysBefore = newValue;
                          });
                          await _settingsService.setDaysBeforePeriod(newValue);
                        }
                      },
                    ),
                  ),
                  const Divider(),
                ],
              ],
            ),
    );
  }
}
