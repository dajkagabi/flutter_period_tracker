import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/utils/cycle_calculator.dart';
import '../../data/daily_log_model.dart';
import '../../data/daily_log_repository.dart';
import 'analytics_overview_screen.dart';
import 'log_daily_data_screen.dart';
import 'settings_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

// A naptár képernyő állapotát kezelő osztály
class _CalendarScreenState extends State<CalendarScreen> {
  final DailyLogRepository _repository = DailyLogRepository();
  final SettingsService _settingsService = SettingsService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // A naptárhoz tartozó adatok
  List<DailyLog> _logs = [];
  // A kiszámított ciklus előrejelzések (múltbeli és jövőbeli)
  List<CyclePrediction> _predictions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  // Adatok betöltése az adatbázisból
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Új: 2020-tól kezdve az ÖSSZES eddigi és jövőbeli adatot betölti
      final start = DateTime(2020, 1, 1);
      final end = DateTime(_focusedDay.year + 2, 12, 31);

      final logs = await _repository.getLogsForRange(start, end);

      List<CyclePrediction> predictions = [];
      try {
        // Visszamenőleg is kiszámoljuk az összes ciklusra az adatsort
        predictions = await CycleCalculator.calculateAllPredictions(logs);
      } catch (_) {
        predictions = [];
      }

      if (!mounted) return;
      setState(() {
        _logs = logs;
        _predictions = predictions;
        _isLoading = false;
      });

      // Az értesítések beállítása (a legutolsó/jövőbeli ciklusra)
      try {
        final isNotificationsEnabled = await _settingsService
            .isNotificationsEnabled();

        // Kikeressük a legfrissebb jövőbeli előrejelzést az értesítéshez
        final futurePrediction = await CycleCalculator.calculatePredictions(
          logs,
        );

        if (futurePrediction != null && isNotificationsEnabled) {
          final daysBefore = await _settingsService.getDaysBeforePeriod();
          await NotificationService().schedulePeriodReminder(
            nextPeriodDate: futurePrediction.nextPeriodStart,
            daysBefore: daysBefore,
          );
        } else if (!isNotificationsEnabled) {
          await NotificationService().cancelAllNotifications();
        }
        // Az értesítés hibája nem akadályozza a naptár megjelenítését
      } catch (_) {}
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _logs = [];
        _predictions = [];
        _isLoading = false;
      });
    }
  }

  // Segédfüggvény: megnézi, hogy két DateTime ugyanarra a napra esik-e
  bool _isSameDayWithoutTime(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Megnézi, hogy az adott nap benne van-e egy intervallumban
  bool _isDateInRange(DateTime day, DateTime start, DateTime end) {
    final dayOnly = DateTime(day.year, day.month, day.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    return !dayOnly.isBefore(startOnly) && !dayOnly.isAfter(endOnly);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cikluskövető'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.pink, size: 28),
            tooltip: 'Összegzés és Grafikonok',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsOverviewScreen(),
                ),
              ).then((_) => _loadData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey, size: 26),
            tooltip: 'Beállítások',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) =>
                      _isSameDayWithoutTime(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                    _loadData();
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildCalendarCell(day, isSelected: false);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildCalendarCell(day, isToday: true);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildCalendarCell(day, isSelected: true);
                    },
                  ),
                ),

                const Divider(height: 16),

                // Jelmagyarázat
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildLegendItem(Colors.red.shade300, 'Menstruáció'),
                      _buildLegendItem(
                        Colors.purple.shade200,
                        'Várható menstruáció',
                      ),
                      _buildLegendItem(Colors.orange.shade300, 'Ovuláció'),
                      _buildLegendItem(
                        Colors.blue.shade200,
                        'Termékeny időszak',
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.edit_note),
                      label: Text(
                        _selectedDay == null
                            ? 'Válassz egy napot'
                            : 'Adatok rögzítése (${_selectedDay!.year}.${_selectedDay!.month}.${_selectedDay!.day}.)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        if (_selectedDay != null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LogDailyDataScreen(
                                selectedDate: _selectedDay!,
                              ),
                            ),
                          );

                          if (result == true) {
                            _loadData();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Cella egyedi megrajzolása
  Widget _buildCalendarCell(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    Color? backgroundColor;

    // Megnézzük, van-e rögzített menstruáció erre a napra
    final logForDay = _logs.cast<DailyLog?>().firstWhere(
      (log) => _isSameDayWithoutTime(log?.date, day),
      orElse: () => null,
    );

    if (logForDay != null &&
        (logForDay.isPeriodStart || logForDay.flowIntensity != null)) {
      //  Valós, rögzített menstruációs nap
      backgroundColor = Colors.red.shade300;
    } else {
      //  Végignézzük az ÖSSZES kiszámított ciklust (múltbelieket és a jövőbelit is)
      for (final pred in _predictions) {
        if (_isSameDayWithoutTime(day, pred.ovulationDate)) {
          backgroundColor = Colors.orange.shade300;
          break;
        } else if (_isDateInRange(
          day,
          pred.fertileWindowStart,
          pred.fertileWindowEnd,
        )) {
          backgroundColor = Colors.blue.shade100;
          break;
        } else {
          // A lila (várható menstruáció) színt csak akkor mutatjuk,
          // ha arra a jósolt ablakra MÉG NEM rögzítettél valódi vérzést
          final hasRecordedPeriodInPredictedWindow = _logs.any(
            (log) =>
                (log.isPeriodStart || log.flowIntensity != null) &&
                log.date.isAfter(
                  pred.nextPeriodStart.subtract(const Duration(days: 7)),
                ) &&
                log.date.isBefore(
                  pred.nextPeriodEnd.add(const Duration(days: 1)),
                ),
          );

          if (_isDateInRange(day, pred.nextPeriodStart, pred.nextPeriodEnd) &&
              !hasRecordedPeriodInPredictedWindow) {
            backgroundColor = Colors.purple.shade100;
            break;
          }
        }
      }
    }

    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.pink, width: 2)
              : isToday
              ? Border.all(color: Colors.grey, width: 1.5)
              : null,
        ),
        child: Center(
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontWeight: (isSelected || isToday || backgroundColor != null)
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isSelected && backgroundColor == null
                  ? Colors.pink
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
