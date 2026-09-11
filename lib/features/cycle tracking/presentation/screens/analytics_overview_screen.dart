import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/features/cycle%20tracking/data/daily_log_model.dart';
import 'package:flutter_period_tracker/features/cycle%20tracking/data/daily_log_repository.dart';

class AnalyticsOverviewScreen extends StatefulWidget {
  const AnalyticsOverviewScreen({super.key});

  @override
  State<AnalyticsOverviewScreen> createState() =>
      _AnalyticsOverviewScreenState();
}

class _AnalyticsOverviewScreenState extends State<AnalyticsOverviewScreen> {
  final DailyLogRepository _repository = DailyLogRepository();
  bool _isLoading = true;
  List<DailyLog> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    // Elmúlt 1 év és a rákövetkező napok lefedése
    final start = DateTime(now.year - 1, now.month, now.day);
    final end = DateTime(now.year + 1, now.month, now.day);

    // Lekérjük az adatokat az adatbázisból
    final logs = await _repository.getLogsForRange(start, end);

    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  // Vérzés erősségének megszámolása
  Map<String, int> _getFlowCounts() {
    final Map<String, int> counts = {};
    for (var log in _logs) {
      if (log.flowIntensity != null && log.flowIntensity!.trim().isNotEmpty) {
        final flow = log.flowIntensity!;
        counts[flow] = (counts[flow] ?? 0) + 1;
      }
    }
    return counts;
  }

  // Hangulatok megszámolása
  Map<String, int> _getMoodCounts() {
    final Map<String, int> counts = {};
    for (var log in _logs) {
      for (var mood in log.moods) {
        if (mood.trim().isNotEmpty) {
          counts[mood] = (counts[mood] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  // Fizikai tünetek megszámolása
  Map<String, int> _getSymptomCounts() {
    final Map<String, int> counts = {};
    for (var log in _logs) {
      for (var symptom in log.physicalSymptoms) {
        if (symptom.trim().isNotEmpty) {
          counts[symptom] = (counts[symptom] ?? 0) + 1;
        }
      }
    }
    return counts;
  }

  // Szín-generáló a kördiagram szeleteihez
  List<Color> get _chartColors => [
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.blueAccent,
    Colors.tealAccent,
    Colors.lightGreenAccent,
  ];

  @override
  Widget build(BuildContext context) {
    final flowCounts = _getFlowCounts();
    final moodCounts = _getMoodCounts();
    final symptomCounts = _getSymptomCounts();

    return Scaffold(
      appBar: AppBar(
        title: const Text(' Összegzés & Statisztika'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Még nincs egyetlen elmentett nap sem az adatbázisban.\n\nMenj vissza a naptárba, ments el egy napot, majd nyomj a frissítésre!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                //
                const Text(
                  ' Vérzés erősségének eloszlása',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: flowCounts.isEmpty
                      ? const Card(
                          child: Center(
                            child: Text(
                              'Nincs rögzített menstruációs adat ebben az időszakban.',
                            ),
                          ),
                        )
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: flowCounts.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                                  final item = entry.value;
                                  // Egyedi pirosas-rózsaszínes árnyalatok a vérzés erősségének
                                  Color color = Colors.red.shade300;
                                  if (item.key == 'enyhe') {
                                    color = Colors.pink.shade200;
                                  } else if (item.key == 'közepes') {
                                    color = Colors.red.shade400;
                                  } else if (item.key == 'erős') {
                                    color = Colors.red.shade800;
                                  }

                                  return PieChartSectionData(
                                    title: '${item.key}\n(${item.value} nap)',
                                    value: item.value.toDouble(),
                                    color: color,
                                    radius: 65,
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                ),

                const Divider(height: 40),

                //
                const Text(
                  ' Hangulatok eloszlása',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: moodCounts.isEmpty
                      ? const Card(
                          child: Center(
                            child: Text(
                              'Nincs rögzített hangulat ebben az időszakban.',
                            ),
                          ),
                        )
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: moodCounts.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  final color =
                                      _chartColors[index % _chartColors.length];
                                  return PieChartSectionData(
                                    title: '${item.key}\n(${item.value})',
                                    value: item.value.toDouble(),
                                    color: color,
                                    radius: 65,
                                    titleStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                ),

                const Divider(height: 40),

                //
                const Text(
                  ' Leggyakoribb fizikai tünetek',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240,
                  child: symptomCounts.isEmpty
                      ? const Card(
                          child: Center(
                            child: Text(
                              'Nincs rögzített fizikai tünet ebben az időszakban.',
                            ),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final keys = symptomCounts.keys.toList();
                                    if (value.toInt() >= 0 &&
                                        value.toInt() < keys.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Text(
                                          keys[value.toInt()],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                            ),
                            barGroups: symptomCounts.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: item.value.toDouble(),
                                        color: Colors.pinkAccent,
                                        width: 18,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  );
                                })
                                .toList(),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
