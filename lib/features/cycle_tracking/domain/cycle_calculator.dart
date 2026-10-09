import 'package:flutter_period_tracker/core/utils/date_utils.dart';

import 'cycle_analysis.dart';
import 'cycle_phase.dart';
import 'cycle_rules.dart';
import 'daily_log.dart';

/// Tiszta (UI- és adatbázis-független) ciklusszámítás.
/// A "mai napot" mindig paraméterként kapja, így determinisztikusan tesztelhető.
abstract final class CycleCalculator {
  /// A naplóbejegyzésekből ciklusokat, átlagokat számol.
  static CycleAnalysis analyze(List<DailyLog> logs) {
    final bleedingDays = <DateTime>{
      for (final log in logs)
        if (log.hasBleeding) dayOnly(log.date),
    }.toList()
      ..sort();
    if (bleedingDays.isEmpty) return CycleAnalysis.empty;

    final endMarks = <DateTime>[
      for (final log in logs)
        if (log.isPeriodEnd) dayOnly(log.date),
    ];

    final episodes = _buildEpisodes(bleedingDays, endMarks);

    // A túl közeli vérzés nem új ciklus, hanem pecsételés / elvérzés.
    final cycleStarts = <BleedingEpisode>[];
    for (final episode in episodes) {
      if (cycleStarts.isEmpty ||
          daysBetween(cycleStarts.last.start, episode.start) >=
              CycleRules.minCycleDays) {
        cycleStarts.add(episode);
      }
    }

    final records = <CycleRecord>[
      for (var i = 0; i < cycleStarts.length; i++)
        CycleRecord(
          start: cycleStarts[i].start,
          nextStart:
              i + 1 < cycleStarts.length ? cycleStarts[i + 1].start : null,
          periodLength:
              cycleStarts[i].hasKnownLength ? cycleStarts[i].length : null,
          periodEnd: cycleStarts[i].end,
        ),
    ];

    final cycleLengths = <int>[
      for (final r in records)
        if (r.hasValidLength) r.length!,
    ];
    final periodLengths = <int>[
      for (final r in records)
        if (r.periodLength != null) r.periodLength!,
    ];

    return CycleAnalysis(
      cycles: records,
      cycleLengths: cycleLengths,
      periodLengths: periodLengths,
      averageCycleLength: cycleLengths.isEmpty
          ? CycleRules.defaultCycleDays
          : _median(_recent(cycleLengths)),
      averagePeriodLength: periodLengths.isEmpty
          ? CycleRules.defaultPeriodDays
          : _mean(_recent(periodLengths))
              .clamp(2, CycleRules.maxPeriodDays)
              .toInt(),
    );
  }

  /// A következő `count` várható menstruáció (a mai naptól kezdve).
  static List<CyclePrediction> predict(
    CycleAnalysis analysis, {
    required DateTime today,
    int count = 3,
  }) {
    final last = analysis.lastStart;
    if (last == null) return const [];

    final todayDay = dayOnly(today);
    final result = <CyclePrediction>[];
    var start = addDays(last, analysis.averageCycleLength);
    for (var i = 0; i < 48 && result.length < count; i++) {
      final prediction = CyclePrediction.fromPeriodStart(
        start,
        periodLength: analysis.averagePeriodLength,
      );
      // Teljesen elmúlt, nem naplózott becslést nem mutatunk.
      if (!prediction.periodEnd.isBefore(todayDay)) result.add(prediction);
      start = addDays(start, analysis.averageCycleLength);
    }
    return result;
  }

  /// Egy adott nap ciklusnapja, fázisa és a következő menstruáció időpontja.
  /// `null`, ha a napot megelőzően nincs rögzített cikluskezdet, vagy túl régi.
  static CycleStatus? statusFor(CycleAnalysis analysis, DateTime date) {
    final day = dayOnly(date);
    CycleRecord? record;
    for (final r in analysis.cycles) {
      if (r.start.isAfter(day)) break;
      record = r;
    }
    if (record == null) return null;

    final cycleDay = daysBetween(record.start, day) + 1;
    if (cycleDay > CycleRules.maxCycleDays) return null;

    final cycleLength = record.hasValidLength
        ? record.length!
        : analysis.averageCycleLength;
    final nextStart =
        record.nextStart ?? addDays(record.start, analysis.averageCycleLength);

    return CycleStatus(
      cycleDay: cycleDay,
      phase: CyclePhaseRules.forDay(
        cycleDay,
        cycleLength: cycleLength,
        periodLength: record.periodLength ?? analysis.averagePeriodLength,
      ),
      nextPeriodStart: nextStart,
      daysUntilNextPeriod: daysBetween(day, nextStart),
      isPrediction: record.nextStart == null,
    );
  }

  /// A naptár jelölései. Fontossági sorrend: vérzés > ovuláció > termékeny > várható vérzés.
  static Map<DateTime, DayMarker> buildMarkers({
    required List<DailyLog> logs,
    required CycleAnalysis analysis,
    required DateTime today,
  }) {
    final map = <DateTime, DayMarker>{};
    final todayDay = dayOnly(today);

    void paint(DateTime from, DateTime to, DayMarker marker) {
      for (var d = dayOnly(from); !d.isAfter(to); d = addDays(d, 1)) {
        map[d] = marker;
      }
    }

    final predictions = predict(analysis, today: today);

    // Lezárt, valós ciklusokra visszamenőleg is becsüljük az ovulációt,
    // de az első rögzített ciklus előtt nem találunk ki adatot.
    final pastEstimates = <CyclePrediction>[
      for (final r in analysis.cycles)
        if (r.hasValidLength)
          CyclePrediction.fromPeriodStart(
            r.nextStart!,
            periodLength: r.periodLength ?? analysis.averagePeriodLength,
          ),
    ];
    final allEstimates = [...pastEstimates, ...predictions];

    for (final p in predictions) {
      paint(p.periodStart, p.periodEnd, DayMarker.predictedPeriod);
    }
    for (final p in allEstimates) {
      paint(p.fertileStart, p.fertileEnd, DayMarker.fertile);
    }
    for (final p in allEstimates) {
      map[p.ovulation] = DayMarker.ovulation;
    }

    // A vérzés teljes időtartamát kijelöljük, nem csak a naplózott napokat:
    // - ismert hossznál a rögzített kezdettől a végéig (a közbeeső napok is),
    // - ha csak a kezdetet naplózták, az átlagos vérzéshosszal kitöltjük,
    //   de a következő ciklus kezdete előtt megállunk.
    // A mai napnál későbbi napok még csak becslések (várható vérzés).
    for (final r in analysis.cycles) {
      var last = r.periodLength != null
          ? r.periodEnd
          : addDays(r.start, analysis.averagePeriodLength - 1);
      final nextStart = r.nextStart;
      if (nextStart != null) {
        final cap = addDays(nextStart, -1);
        if (last.isAfter(cap)) last = cap;
      }
      for (var d = r.start; !d.isAfter(last); d = addDays(d, 1)) {
        map[d] = d.isAfter(todayDay) ? DayMarker.predictedPeriod : DayMarker.period;
      }
    }

    // A ténylegesen naplózott vérzéses napok mindig vérzésként jelennek meg.
    for (final log in logs) {
      if (log.hasBleeding) map[dayOnly(log.date)] = DayMarker.period;
    }
    return map;
  }

  // ---------------------------------------------------------------------------

  static List<BleedingEpisode> _buildEpisodes(
    List<DateTime> sortedDays,
    List<DateTime> endMarks,
  ) {
    final groups = <List<DateTime>>[];
    for (final d in sortedDays) {
      if (groups.isNotEmpty &&
          daysBetween(groups.last.last, d) <=
              CycleRules.maxGapWithinPeriodDays + 1) {
        groups.last.add(d);
      } else {
        groups.add([d]);
      }
    }

    final episodes = <BleedingEpisode>[];
    for (var i = 0; i < groups.length; i++) {
      final start = groups[i].first;
      var end = groups[i].last;
      final nextStart = i + 1 < groups.length ? groups[i + 1].first : null;

      // A "menstruáció vége" jelölés kiterjeszti az időszakot.
      for (final mark in endMarks) {
        final inRange = !mark.isBefore(start) &&
            daysBetween(start, mark) <= CycleRules.maxPeriodDays &&
            (nextStart == null || mark.isBefore(nextStart));
        if (inRange && mark.isAfter(end)) end = mark;
      }
      episodes.add(BleedingEpisode(start: start, end: end));
    }
    return episodes;
  }

  static List<int> _recent(List<int> values) =>
      values.length > CycleRules.recentCyclesForAverage
          ? values.sublist(values.length - CycleRules.recentCyclesForAverage)
          : values;

  static int _median(List<int> values) {
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : ((sorted[mid - 1] + sorted[mid]) / 2).round();
  }

  static int _mean(List<int> values) =>
      (values.reduce((a, b) => a + b) / values.length).round();
}
