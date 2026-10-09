import 'package:flutter/foundation.dart';
import 'package:flutter_period_tracker/core/utils/date_utils.dart';

import 'cycle_phase.dart';
import 'cycle_rules.dart';

/// Összefüggő vérzéses időszak a naplóban.
@immutable
class BleedingEpisode {
  const BleedingEpisode({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  int get length => daysBetween(start, end) + 1;

  /// A hossz csak akkor megbízható, ha több napot rögzítettek vagy megjelölték a végét.
  bool get hasKnownLength => end.isAfter(start);
}

/// Egy rögzített ciklus: a menstruáció kezdetétől a következő kezdetéig.
@immutable
class CycleRecord {
  const CycleRecord({
    required this.start,
    required this.nextStart,
    required this.periodLength,
    required this.periodEnd,
  });

  final DateTime start;
  final DateTime? nextStart;

  /// A vérzés hossza; `null`, ha nem ismert (csak a kezdetet naplózták).
  final int? periodLength;

  /// A rögzített vérzés utolsó napja (ismeretlen hossznál megegyezik a kezdettel).
  final DateTime periodEnd;

  int? get length => nextStart == null ? null : daysBetween(start, nextStart!);

  bool get hasValidLength {
    final l = length;
    return l != null &&
        l >= CycleRules.minCycleDays &&
        l <= CycleRules.maxCycleDays;
  }
}

@immutable
class CycleAnalysis {
  const CycleAnalysis({
    required this.cycles,
    required this.cycleLengths,
    required this.periodLengths,
    required this.averageCycleLength,
    required this.averagePeriodLength,
  });

  static const CycleAnalysis empty = CycleAnalysis(
    cycles: [],
    cycleLengths: [],
    periodLengths: [],
    averageCycleLength: CycleRules.defaultCycleDays,
    averagePeriodLength: CycleRules.defaultPeriodDays,
  );

  final List<CycleRecord> cycles;

  /// Lezárt, hihető hosszúságú ciklusok hossza (időrendben).
  final List<int> cycleLengths;
  final List<int> periodLengths;
  final int averageCycleLength;
  final int averagePeriodLength;

  bool get hasData => cycles.isNotEmpty;
  DateTime? get lastStart => cycles.isEmpty ? null : cycles.last.start;

  /// Legalább két lezárt ciklus után tekinthető az átlag megbízhatónak.
  bool get isReliable => cycleLengths.length >= 2;

  /// A ciklushosszak terjedelme (max - min), szabálytalanság jelzéséhez.
  int get cycleLengthRange => cycleLengths.length < 2
      ? 0
      : cycleLengths.reduce((a, b) => a > b ? a : b) -
          cycleLengths.reduce((a, b) => a < b ? a : b);
}

/// Előrejelzés egy várható menstruációra és az azt megelőző termékeny ablakra.
@immutable
class CyclePrediction {
  const CyclePrediction({
    required this.periodStart,
    required this.periodEnd,
    required this.ovulation,
    required this.fertileStart,
    required this.fertileEnd,
  });

  factory CyclePrediction.fromPeriodStart(
    DateTime periodStart, {
    required int periodLength,
  }) {
    final ovulation = addDays(periodStart, -CycleRules.lutealPhaseDays);
    return CyclePrediction(
      periodStart: periodStart,
      periodEnd: addDays(periodStart, periodLength - 1),
      ovulation: ovulation,
      fertileStart: addDays(ovulation, -CycleRules.fertileDaysBeforeOvulation),
      fertileEnd: addDays(ovulation, 1),
    );
  }

  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime ovulation;
  final DateTime fertileStart;
  final DateTime fertileEnd;
}

/// Egy adott nap ciklus-állapota.
@immutable
class CycleStatus {
  const CycleStatus({
    required this.cycleDay,
    required this.phase,
    required this.nextPeriodStart,
    required this.daysUntilNextPeriod,
    required this.isPrediction,
  });

  final int cycleDay;
  final CyclePhase phase;
  final DateTime nextPeriodStart;

  /// A vizsgált naptól számítva (negatív: késik a becsült időponthoz képest).
  final int daysUntilNextPeriod;

  /// Igaz, ha a következő kezdet becslés (még nincs rögzítve).
  final bool isPrediction;
}

/// A naptár napjainak jelölése.
enum DayMarker { period, predictedPeriod, ovulation, fertile }
