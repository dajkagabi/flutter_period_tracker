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
  // Segédfüggvény a ciklusok valódi kezdőnapjainak kiszűrésére
  static List<DateTime> _getActualStarts(List<DailyLog> logs) {
    final periodStarts = logs
        .where((log) => log.isPeriodStart == true || log.flowIntensity != null)
        .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
        .toList();

    if (periodStarts.isEmpty) return [];

    periodStarts.sort((a, b) => a.compareTo(b));

    final List<DateTime> actualStarts = [];
    for (var date in periodStarts) {
      if (actualStarts.isEmpty ||
          date.difference(actualStarts.last).inDays > 14) {
        actualStarts.add(date);
      }
    }
    return actualStarts;
  }

  // Ugyanaz a ciklushossz-számító logika
  static int _getCycleLength(List<DateTime> actualStarts) {
    if (actualStarts.length >= 2) {
      int totalDays = 0;
      for (int i = 0; i < actualStarts.length - 1; i++) {
        totalDays += actualStarts[i + 1].difference(actualStarts[i]).inDays;
      }
      return (totalDays / (actualStarts.length - 1)).round();
    }
    // Tankönyvi átlag
    return 28;
  }

  // Visszamenőleg kiszámol minden
  // korábbi és jövőbeli ciklushoz tartozó ovulációt/termékeny napot
  static Future<List<CyclePrediction>> calculateAllPredictions(
    List<DailyLog> logs,
  ) async {
    final actualStarts = _getActualStarts(logs);
    if (actualStarts.isEmpty) return [];

    final List<CyclePrediction> predictions = [];
    final int avgCycleLength = _getCycleLength(actualStarts);
    const int calculatedPeriodLength = 5;
    final firstStart = actualStarts.first;
    var estimatedPreviousStart = firstStart.subtract(
      Duration(days: avgCycleLength),
    );
    final earliestCalculatedDate = DateTime(2020, 1, 1);

    // A legkorábbi rögzített ciklus előtti időszakokat is megjelenítjük
    // becslésként, az átlagos ciklushossz alapján.
    while (!estimatedPreviousStart.isBefore(earliestCalculatedDate)) {
      final estimatedPeriodEnd = estimatedPreviousStart.add(
        const Duration(days: calculatedPeriodLength - 1),
      );
      final estimatedOvulation = estimatedPreviousStart.subtract(
        const Duration(days: 14),
      );

      predictions.insert(
        0,
        CyclePrediction(
          nextPeriodStart: estimatedPreviousStart,
          nextPeriodEnd: estimatedPeriodEnd,
          ovulationDate: estimatedOvulation,
          fertileWindowStart: estimatedOvulation.subtract(
            const Duration(days: 5),
          ),
          fertileWindowEnd: estimatedOvulation.add(const Duration(days: 1)),
        ),
      );
      estimatedPreviousStart = estimatedPreviousStart.subtract(
        Duration(days: avgCycleLength),
      );
    }

    // Múltbeli és jelenlegi rögzített ciklusok feldolgozása
    for (int i = 0; i < actualStarts.length; i++) {
      final currentStart = actualStarts[i];

      // A rákövetkező ciklus kezdete
      // (ha van rögzítve, akkor az, ha nincs, az átlagos ciklushosszal számolunk)
      final DateTime rawNextStart = (i < actualStarts.length - 1)
          ? actualStarts[i + 1]
          : currentStart.add(Duration(days: avgCycleLength));

      // Normalizáljuk az időpontokat éjfélre (00:00:00),
      // hogy a naptár pontosan egyeztesse a napokat
      final nextStart = DateTime(
        rawNextStart.year,
        rawNextStart.month,
        rawNextStart.day,
      );

      final nextEnd = nextStart.add(
        const Duration(days: calculatedPeriodLength - 1),
      );

      // Ovuláció és termékeny ablak visszaszámolása a következő cikluskezdetből
      final ovulationDate = DateTime(
        nextStart.year,
        nextStart.month,
        nextStart.day,
      ).subtract(const Duration(days: 14));

      final fertileWindowStart = ovulationDate.subtract(
        const Duration(days: 5),
      );
      final fertileWindowEnd = ovulationDate.add(const Duration(days: 1));

      predictions.add(
        CyclePrediction(
          nextPeriodStart: nextStart,
          nextPeriodEnd: nextEnd,
          ovulationDate: ovulationDate,
          fertileWindowStart: fertileWindowStart,
          fertileWindowEnd: fertileWindowEnd,
        ),
      );
    }

    // Egy legfrissebb jövőbeli előrejelzés hozzáadása
    final futurePrediction = await calculatePredictions(logs);
    if (futurePrediction != null) {
      predictions.add(futurePrediction);
    }

    return predictions;
  }

  // Az eredeti jövőbeli előrejelző metódusod
  // (megtartva az értesítésekhez és jövőbeli becslésekhez)
  static Future<CyclePrediction?> calculatePredictions(
    List<DailyLog> logs,
  ) async {
    final actualStarts = _getActualStarts(logs);
    if (actualStarts.isEmpty) return null;

    final int calculatedCycleLength = _getCycleLength(actualStarts);
    const int calculatedPeriodLength = 5;

    final lastPeriodStart = actualStarts.last;

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

    final normalizedNextStart = DateTime(
      nextPeriodStart.year,
      nextPeriodStart.month,
      nextPeriodStart.day,
    );

    final nextPeriodEnd = normalizedNextStart.add(
      const Duration(days: calculatedPeriodLength - 1),
    );

    final ovulationDate = normalizedNextStart.subtract(
      const Duration(days: 14),
    );
    final fertileWindowStart = ovulationDate.subtract(const Duration(days: 5));
    final fertileWindowEnd = ovulationDate.add(const Duration(days: 1));

    return CyclePrediction(
      nextPeriodStart: normalizedNextStart,
      nextPeriodEnd: nextPeriodEnd,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileWindowStart,
      fertileWindowEnd: fertileWindowEnd,
    );
  }
}
