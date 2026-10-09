import 'cycle_rules.dart';

enum CyclePhase { menstrual, follicular, ovulatory, luteal }

abstract final class CyclePhaseRules {
  /// Ciklusfázis a ciklusnap, a ciklushossz és a vérzés hossza alapján.
  /// Ugyanazt az ovulációs napot használja, mint a naptár (hossz - 14).
  static CyclePhase forDay(
    int cycleDay, {
    required int cycleLength,
    required int periodLength,
  }) {
    final ovulationDay = cycleLength - CycleRules.lutealPhaseDays;
    if (cycleDay <= periodLength) return CyclePhase.menstrual;
    if (cycleDay < ovulationDay - 1) return CyclePhase.follicular;
    if (cycleDay <= ovulationDay + 1) return CyclePhase.ovulatory;
    return CyclePhase.luteal;
  }
}
