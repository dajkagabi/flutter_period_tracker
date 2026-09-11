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
  static CyclePrediction? calculatePredictions(List<dynamic> logs) {
    // Megkeressük az összes rögzített menstruáció kezdőnapját
    final periodStarts = logs
        .where((log) => log.isPeriodStart == true || log.flowIntensity != null)
        .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
        .toList();

    if (periodStarts.isEmpty) return null;

    // Rendezzük dátum szerint csökkenő sorrendbe (a legfrissebb az első)
    periodStarts.sort((a, b) => b.compareTo(a));

    final lastPeriodStart = periodStarts.first;

    // Alapértelmezett értékek, ha még nincs elég mentett adata a felhasználónak
    //Átlagos ciklushossz: 28 nap (tankönyvi érték)
    //Egy ciklus : 21 - 35 nap
    int cycleLength = 21;
    int periodLength = 5;

    // Következő menstruáció számítása
    DateTime nextPeriodStart = lastPeriodStart.add(Duration(days: cycleLength));
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Ha a kiszámolt következő menstruáció dátuma már elmúlt vagy rögzítve lett,
    // hozzáadunk még egy ciklust (+21napot), hogy a JÖVŐBELI hónapra saccoljon!
    while (nextPeriodStart.isBefore(todayOnly) ||
        periodStarts.any(
          (p) =>
              p.year == nextPeriodStart.year &&
              p.month == nextPeriodStart.month,
        )) {
      nextPeriodStart = nextPeriodStart.add(Duration(days: cycleLength));
    }

    final nextPeriodEnd = nextPeriodStart.add(Duration(days: periodLength - 1));

    // Ovuláció: a következő menstruáció előtt ~14 nappal
    final ovulationDate = nextPeriodStart.subtract(const Duration(days: 14));

    // Termékeny ablak: ovuláció előtt 5 nap, utána 1 nap
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
