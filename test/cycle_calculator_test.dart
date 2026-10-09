import 'package:flutter_period_tracker/core/utils/date_utils.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/domain/cycle_analysis.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/domain/cycle_calculator.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/domain/cycle_phase.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/domain/cycle_rules.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/domain/daily_log.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime d(String key) => parseDayKey(key);

DailyLog start(String day) => DailyLog(date: d(day), isPeriodStart: true);

DailyLog flow(String day) =>
    DailyLog(date: d(day), flow: FlowIntensity.medium);

void main() {
  group('analyze', () {
    test('nincs adat: alapértékek', () {
      final a = CycleCalculator.analyze(const []);
      expect(a.hasData, isFalse);
      expect(a.averageCycleLength, CycleRules.defaultCycleDays);
      expect(a.averagePeriodLength, CycleRules.defaultPeriodDays);
    });

    test('rendszeres 28 napos ciklusok', () {
      final a = CycleCalculator.analyze([
        start('2026-01-01'),
        start('2026-01-29'),
        start('2026-02-26'),
      ]);
      expect(a.cycleLengths, [28, 28]);
      expect(a.averageCycleLength, 28);
      expect(a.isReliable, isTrue);
    });

    test('óraátállás (márc. 29.) nem csúsztatja a ciklushosszt', () {
      final a = CycleCalculator.analyze([
        start('2026-03-01'),
        start('2026-03-30'),
      ]);
      expect(a.cycleLengths, [29]);
    });

    test('a közeli vérzés pecsételésnek számít, nem új ciklus', () {
      final a = CycleCalculator.analyze([
        for (final day in [
          '2026-01-01',
          '2026-01-02',
          '2026-01-03',
          '2026-01-04',
          '2026-01-05',
          '2026-01-10',
        ])
          flow(day),
      ]);
      expect(a.cycles.length, 1);
      expect(a.periodLengths, [5]);
    });

    test('kihagyott naplózás (túl hosszú ciklus) kimarad az átlagból', () {
      final a = CycleCalculator.analyze([
        start('2026-01-01'),
        start('2026-01-29'),
        start('2026-02-26'),
        start('2026-06-01'),
      ]);
      expect(a.cycles.length, 4);
      expect(a.cycleLengths, [28, 28]);
    });

    test('az átlag a medián, nem a számtani közép', () {
      final a = CycleCalculator.analyze([
        start('2026-01-01'),
        start('2026-01-29'), // 28
        start('2026-02-28'), // 30
        start('2026-03-28'), // 28
      ]);
      expect(a.cycleLengths, [28, 30, 28]);
      expect(a.averageCycleLength, 28);
    });

    test('a "menstruáció vége" jelölés megadja a vérzés hosszát', () {
      final a = CycleCalculator.analyze([
        start('2026-01-01'),
        DailyLog(date: d('2026-01-05'), isPeriodEnd: true),
      ]);
      expect(a.periodLengths, [5]);
    });
  });

  group('predict', () {
    final analysis = CycleCalculator.analyze([
      start('2026-01-01'),
      start('2026-01-29'),
      start('2026-02-26'),
    ]);

    test('a következő három várható menstruáció', () {
      final p = CycleCalculator.predict(analysis, today: d('2026-03-10'));
      expect(p.map((e) => dayKey(e.periodStart)),
          ['2026-03-26', '2026-04-23', '2026-05-21']);
      expect(dayKey(p.first.periodEnd), '2026-03-30');
      expect(dayKey(p.first.ovulation), '2026-03-12');
    });

    test('nincs adat: nincs előrejelzés', () {
      expect(
        CycleCalculator.predict(CycleAnalysis.empty, today: d('2026-03-10')),
        isEmpty,
      );
    });
  });

  group('statusFor', () {
    final analysis = CycleCalculator.analyze([
      start('2026-01-01'),
      start('2026-01-29'),
    ]);

    test('lezárt ciklus napja', () {
      final s = CycleCalculator.statusFor(analysis, d('2026-01-10'))!;
      expect(s.cycleDay, 10);
      expect(s.phase, CyclePhase.follicular);
      expect(dayKey(s.nextPeriodStart), '2026-01-29');
      expect(s.daysUntilNextPeriod, 19);
      expect(s.isPrediction, isFalse);
    });

    test('a jelenlegi ciklus következő kezdete becslés', () {
      final s = CycleCalculator.statusFor(analysis, d('2026-02-05'))!;
      expect(s.cycleDay, 8);
      expect(s.isPrediction, isTrue);
      expect(dayKey(s.nextPeriodStart), '2026-02-26');
      expect(s.daysUntilNextPeriod, 21);
    });

    test('az első cikluskezdet előtt nincs állapot', () {
      expect(CycleCalculator.statusFor(analysis, d('2025-12-31')), isNull);
    });
  });

  group('phase', () {
    test('28 napos ciklus, 5 napos vérzés', () {
      CyclePhase at(int day) =>
          CyclePhaseRules.forDay(day, cycleLength: 28, periodLength: 5);
      expect(at(1), CyclePhase.menstrual);
      expect(at(5), CyclePhase.menstrual);
      expect(at(10), CyclePhase.follicular);
      expect(at(14), CyclePhase.ovulatory);
      expect(at(20), CyclePhase.luteal);
    });

    test('hosszabb ciklusnál később jön az ovuláció', () {
      CyclePhase at(int day) =>
          CyclePhaseRules.forDay(day, cycleLength: 35, periodLength: 5);
      expect(at(14), CyclePhase.follicular);
      expect(at(21), CyclePhase.ovulatory);
      expect(at(25), CyclePhase.luteal);
    });
  });

  group('buildMarkers', () {
    final logs = [start('2026-01-01'), start('2026-01-29'), start('2026-02-26')];
    final analysis = CycleCalculator.analyze(logs);
    final markers = CycleCalculator.buildMarkers(
      logs: logs,
      analysis: analysis,
      today: d('2026-03-10'),
    );

    test('rögzített, várható, ovulációs és termékeny napok', () {
      expect(markers[d('2026-01-01')], DayMarker.period);
      expect(markers[d('2026-03-26')], DayMarker.predictedPeriod);
      expect(markers[d('2026-03-12')], DayMarker.ovulation);
      expect(markers[d('2026-03-09')], DayMarker.fertile);
    });

    test('ha csak a kezdetet naplózták, az átlagos hosszig kitölti', () {
      final l = [start('2026-01-01'), start('2026-01-29')];
      final m = CycleCalculator.buildMarkers(
        logs: l,
        analysis: CycleCalculator.analyze(l),
        today: d('2026-02-10'),
      );
      expect(m[d('2026-01-03')], DayMarker.period);
      expect(m[d('2026-01-05')], DayMarker.period);
      expect(m[d('2026-01-06')], isNot(DayMarker.period));
    });

    test('a folyamatban lévő vérzés jövőbeli napjai csak becslések', () {
      final l = [start('2026-01-01')];
      final m = CycleCalculator.buildMarkers(
        logs: l,
        analysis: CycleCalculator.analyze(l),
        today: d('2026-01-03'),
      );
      expect(m[d('2026-01-02')], DayMarker.period);
      expect(m[d('2026-01-04')], DayMarker.predictedPeriod);
    });

    test('naplózott napok közti hézag is kitöltődik', () {
      final l = [flow('2026-01-01'), flow('2026-01-02'), flow('2026-01-04')];
      final m = CycleCalculator.buildMarkers(
        logs: l,
        analysis: CycleCalculator.analyze(l),
        today: d('2026-02-10'),
      );
      expect(m[d('2026-01-03')], DayMarker.period);
    });

    test('az első rögzített ciklus előtt nem találunk ki adatot', () {
      expect(markers[d('2025-12-01')], isNull);
      expect(markers[d('2025-12-15')], isNull);
    });
  });

  group('date utils', () {
    test('dayKey kör-úton stabil', () {
      expect(dayKey(parseDayKey('2026-03-01')), '2026-03-01');
      expect(daysBetween(d('2026-03-28'), d('2026-03-30')), 2);
      expect(dayKey(addDays(d('2026-01-31'), 1)), '2026-02-01');
    });
  });
}
