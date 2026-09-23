import '../../features/cycle tracking/data/daily_log_model.dart';

// Menstruációs ciklus előrejelző osztály
class CyclePrediction {
  final DateTime nextPeriodStart;
  final DateTime nextPeriodEnd;
  final DateTime ovulationDate;
  final DateTime fertileWindowStart;
  final DateTime fertileWindowEnd;

  CyclePrediction({
    required this.nextPeriodStart,
    required this.nextPeriodEnd,
    required this.ovulationDate,
    required this.fertileWindowStart,
    required this.fertileWindowEnd,
  });
}

class CycleCalculator {
  static Future<CyclePrediction?> calculatePredictions(
    List<DailyLog> logs,
  ) async {
    // 1. Összes rögzített menstruációs kezdőnap megkeresése
    final periodStarts = logs
        .where((log) => log.isPeriodStart == true || log.flowIntensity != null)
        .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
        .toList();

    if (periodStarts.isEmpty) return null;

    periodStarts.sort((a, b) => a.compareTo(b));

    // Csak az egyes ciklusok kezdőnapjait gyűjtjük ki
    final List<DateTime> actualStarts = [];
    for (var date in periodStarts) {
      if (actualStarts.isEmpty ||
          date.difference(actualStarts.last).inDays > 14) {
        actualStarts.add(date);
      }
    }

    int calculatedCycleLength = 28; // Alapértelmezett orvosi átlag
    int calculatedPeriodLength = 5;

    // 2. Ha van legalább 2 rögzítés, automatikusan kiszámolja a valós átlagot:
    if (actualStarts.length >= 2) {
      int totalDays = 0;
      for (int i = 0; i < actualStarts.length - 1; i++) {
        totalDays += actualStarts[i + 1].difference(actualStarts[i]).inDays;
      }
      calculatedCycleLength = (totalDays / (actualStarts.length - 1)).round();
    }

    final lastPeriodStart = actualStarts.last;

    // Következő menstruáció kiszámítása
    DateTime nextPeriodStart = lastPeriodStart.add(
      Duration(days: calculatedCycleLength),
    );
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    while (nextPeriodStart.isBefore(todayOnly) ||
        actualStarts.any(
          (p) =>
              p.year == nextPeriodStart.year &&
              p.month == nextPeriodStart.month,
        )) {
      nextPeriodStart = nextPeriodStart.add(
        Duration(days: calculatedCycleLength),
      );
    }

    final nextPeriodEnd = nextPeriodStart.add(
      Duration(days: calculatedPeriodLength - 1),
    );

    // Ovuláció és termékeny napok
    final ovulationDate = nextPeriodStart.subtract(const Duration(days: 14));
    final fertileWindowStart = ovulationDate.subtract(const Duration(days: 5));
    final fertileWindowEnd = ovulationDate.add(const Duration(days: 1));

    return CyclePrediction(
      nextPeriodStart: nextPeriodStart,
      nextPeriodEnd: nextPeriodEnd,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileWindowStart,
      fertileWindowEnd: fertileWindowEnd,
    );
  }
}
