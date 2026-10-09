/// A ciklusszámítás konfigurálható szabályai egy helyen.
abstract final class CycleRules {
  static const int defaultCycleDays = 28;
  static const int defaultPeriodDays = 5;

  /// Luteális fázis hossza (az ovuláció a következő menstruáció előtt ennyi nappal).
  static const int lutealPhaseDays = 14;

  /// Ennél rövidebb két cikluskezdet közötti távolság nem ciklus,
  /// hanem pecsételő vérzés (nem számít új ciklusnak).
  static const int minCycleDays = 15;

  /// Ennél hosszabb ciklus kihagyott naplózásra utal, az átlagból kihagyjuk.
  static const int maxCycleDays = 60;

  /// Egy vérzési időszakon belül ennyi naplózatlan nap még összetartozónak számít.
  static const int maxGapWithinPeriodDays = 2;

  /// Egy menstruáció legfeljebb ennyi napig tart (a "vége" jelölés ellenőrzéséhez).
  static const int maxPeriodDays = 10;

  /// Hány utolsó ciklusból számolunk átlagot.
  static const int recentCyclesForAverage = 6;

  /// A termékeny ablak az ovuláció előtt ennyi nappal kezdődik.
  static const int fertileDaysBeforeOvulation = 5;
}
