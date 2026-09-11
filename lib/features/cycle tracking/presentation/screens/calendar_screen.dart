import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/features/cycle%20tracking/presentation/screens/analytics_overview_screen.dart';
import 'package:flutter_period_tracker/features/cycle%20tracking/presentation/screens/log_daily_data_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/utils/cycle_calculator.dart';
import '../../data/daily_log_model.dart';
import '../../data/daily_log_repository.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DailyLogRepository _repository = DailyLogRepository();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<DailyLog> _logs = [];
  CyclePrediction? _prediction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  // Adatok betöltése az adatbázisból és a predikciók kiszámítása
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Lekérjük az elmúlt fél év és a következő fél év adatait
    final start = DateTime(_focusedDay.year, _focusedDay.month - 6, 1);
    final end = DateTime(_focusedDay.year, _focusedDay.month + 6, 30);

    final logs = await _repository.getLogsForRange(start, end);
    final prediction = CycleCalculator.calculatePredictions(logs);

    setState(() {
      _logs = logs;
      _prediction = prediction;
      _isLoading = false;
    });
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
        title: const Text(' Cikluskövető'),
        actions: [
          // Gomb az összegzés és grafikonok képernyőre
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.pink, size: 28),
            tooltip: 'Összegzés és Grafikonok',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalyticsOverviewScreen(),
                ),
              ).then((_) => _loadData()); // Visszatéréskor frissíti a naptárat
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 1. NAPTÁR NÉZET
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
                  },

                  // Egyedi színezés a ciklusfázisoknak minden nézetben
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

                const Divider(height: 32),

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

                // Gomb a naplózáshoz
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
                          // Megnyitjuk a Naplózó képernyőt
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LogDailyDataScreen(
                                selectedDate: _selectedDay!,
                              ),
                            ),
                          );

                          // Ha mentettünk adatot, újra betöltjük a naptárt
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

  // Cella egyedi megrajzolása a ciklus állapota alapján
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

    // Ellenőrizzük, hogy a várható intervallumban vagy az előtt van-e már rögzített menstruáció
    final hasRecordedPeriodInPredictedWindow =
        _prediction != null &&
        _logs.any(
          (log) =>
              (log.isPeriodStart || log.flowIntensity != null) &&
              log.date.isAfter(
                _prediction!.nextPeriodStart.subtract(const Duration(days: 7)),
              ) &&
              log.date.isBefore(
                _prediction!.nextPeriodEnd.add(const Duration(days: 1)),
              ),
        );

    if (logForDay != null &&
        (logForDay.isPeriodStart || logForDay.flowIntensity != null)) {
      // 1. Valós, rögzített menstruációs nap -> PIROS
      backgroundColor = Colors.red.shade300;
    } else if (_prediction != null) {
      // 2. Ovuláció napja
      if (_isSameDayWithoutTime(day, _prediction!.ovulationDate)) {
        backgroundColor = Colors.orange.shade300;
      }
      // 3. Termékeny időszak
      else if (_isDateInRange(
        day,
        _prediction!.fertileWindowStart,
        _prediction!.fertileWindowEnd,
      )) {
        backgroundColor = Colors.blue.shade100;
      }
      // 4. Várható menstruáció -> Csak akkor rajzoljuk ki LILÁVAL,
      // ha abban az időszakban MÉG NEM volt rögzítve valós vérzés!
      else if (_isDateInRange(
            day,
            _prediction!.nextPeriodStart,
            _prediction!.nextPeriodEnd,
          ) &&
          !hasRecordedPeriodInPredictedWindow) {
        backgroundColor = Colors.purple.shade100;
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
