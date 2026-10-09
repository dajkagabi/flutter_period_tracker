import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_period_tracker/core/providers.dart';
import 'package:flutter_period_tracker/core/services/notification_service.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/domain/cycle_calculator.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/presentation/providers/cycle_providers.dart';
import 'package:flutter_period_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Az "közeleg a menstruáció" értesítést mindig a legfrissebb adatokhoz igazítja.
/// Az app gyökerében kell figyelni (`ref.watch`), nem a naptár képernyő feladata.
/// Csak a saját értesítését törli/ütemezi, az orvosi emlékeztetőkhöz nem nyúl.
final periodReminderSyncProvider = Provider<void>((ref) {
  final logs = ref.watch(dailyLogsProvider);
  if (!logs.hasValue) return; // betöltés közben ne töröljük a meglévő ütemezést

  final settings = ref.watch(settingsProvider);
  final analysis = ref.watch(cycleAnalysisProvider);
  final today = ref.watch(todayProvider);
  final service = ref.watch(notificationServiceProvider);

  unawaited(() async {
    try {
      await service.cancel(NotificationIds.periodReminder);
      if (!settings.periodReminderEnabled) return;
      for (final p in CycleCalculator.predict(analysis, today: today)) {
        final scheduled = await service.schedulePeriodReminder(
          periodStart: p.periodStart,
          daysBefore: settings.daysBefore,
        );
        if (scheduled) break;
      }
    } catch (e, st) {
      debugPrint('Értesítés ütemezése sikertelen: $e\n$st');
    }
  }());
});
