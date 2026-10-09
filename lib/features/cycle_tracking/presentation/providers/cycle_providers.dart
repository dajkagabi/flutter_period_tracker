import 'package:flutter_period_tracker/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daily_log_repository.dart';
import '../../data/sqlite_daily_log_repository.dart';
import '../../domain/cycle_analysis.dart';
import '../../domain/cycle_calculator.dart';
import '../../domain/daily_log.dart';

final dailyLogRepositoryProvider = Provider<DailyLogRepository>(
  (ref) => SqliteDailyLogRepository(ref.watch(appDatabaseProvider)),
);

/// Az összes naplóbejegyzés. Mentés után közvetlenül frissül az állapot,
/// így a naptár nem villan és nem tölt újra.
class DailyLogsNotifier extends AsyncNotifier<List<DailyLog>> {
  DailyLogRepository get _repo => ref.read(dailyLogRepositoryProvider);

  @override
  Future<List<DailyLog>> build() => ref.watch(dailyLogRepositoryProvider).getAll();

  /// Üres bejegyzést nem tárolunk – az törlésnek számít.
  Future<void> save(DailyLog log) async {
    if (log.isEmpty) {
      await _repo.delete(log.date);
    } else {
      await _repo.save(log);
    }
    state = AsyncData(await _repo.getAll());
  }

  Future<void> delete(DateTime date) async {
    await _repo.delete(date);
    state = AsyncData(await _repo.getAll());
  }
}

final dailyLogsProvider =
    AsyncNotifierProvider<DailyLogsNotifier, List<DailyLog>>(
  DailyLogsNotifier.new,
);

final cycleAnalysisProvider = Provider<CycleAnalysis>((ref) {
  final logs = ref.watch(dailyLogsProvider).valueOrNull ?? const <DailyLog>[];
  return CycleCalculator.analyze(logs);
});

final calendarMarkersProvider = Provider<Map<DateTime, DayMarker>>((ref) {
  final logs = ref.watch(dailyLogsProvider).valueOrNull ?? const <DailyLog>[];
  return CycleCalculator.buildMarkers(
    logs: logs,
    analysis: ref.watch(cycleAnalysisProvider),
    today: ref.watch(todayProvider),
  );
});

final cycleStatusProvider = Provider.family<CycleStatus?, DateTime>(
  (ref, date) =>
      CycleCalculator.statusFor(ref.watch(cycleAnalysisProvider), date),
);
