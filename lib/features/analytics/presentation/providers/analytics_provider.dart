import 'package:flutter/foundation.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/domain/daily_log.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/presentation/providers/cycle_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AnalyticsData {
  const AnalyticsData({
    required this.cycleLengths,
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.hasCycleLengthData,
    required this.hasPeriodLengthData,
    required this.cycleLengthRange,
    required this.flowCounts,
    required this.symptomCounts,
  });

  final List<int> cycleLengths;
  final int averageCycleLength;
  final int averagePeriodLength;

  /// Hamis, ha nincs valódi adat – ilyenkor "—" jelenik meg, nem kitalált szám.
  final bool hasCycleLengthData;
  final bool hasPeriodLengthData;
  final int cycleLengthRange;
  final Map<FlowIntensity, int> flowCounts;

  /// Gyakoriság szerint csökkenő sorrendben.
  final List<MapEntry<PhysicalSymptom, int>> symptomCounts;
}

final analyticsProvider = Provider<AnalyticsData>((ref) {
  final logs = ref.watch(dailyLogsProvider).valueOrNull ?? const <DailyLog>[];
  final analysis = ref.watch(cycleAnalysisProvider);

  final flow = <FlowIntensity, int>{};
  final symptoms = <PhysicalSymptom, int>{};
  for (final log in logs) {
    final f = log.flow;
    if (f != null) flow[f] = (flow[f] ?? 0) + 1;
    for (final s in log.physicalSymptoms) {
      symptoms[s] = (symptoms[s] ?? 0) + 1;
    }
  }

  return AnalyticsData(
    cycleLengths: analysis.cycleLengths,
    averageCycleLength: analysis.averageCycleLength,
    averagePeriodLength: analysis.averagePeriodLength,
    hasCycleLengthData: analysis.cycleLengths.isNotEmpty,
    hasPeriodLengthData: analysis.periodLengths.isNotEmpty,
    cycleLengthRange: analysis.cycleLengthRange,
    flowCounts: flow,
    symptomCounts: symptoms.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)),
  );
});
