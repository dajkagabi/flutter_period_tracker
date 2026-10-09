import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_period_tracker/features/reminders/application/period_reminder_sync.dart';
import 'package:flutter_period_tracker/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class PeriodTrackerApp extends ConsumerWidget {
  const PeriodTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Háttérben élő szinkronizálók: az értesítések ütemezése az adatokhoz igazodik.
    // `listen`, hogy a MaterialApp ne épüljön újra minden változásnál.
    ref.listen<void>(periodReminderSyncProvider, (_, __) {});
    ref.listen(remindersProvider, (_, __) {});

    return MaterialApp(
      title: 'Cikluskövető',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      locale: const Locale('hu', 'HU'),
      supportedLocales: const [Locale('hu', 'HU')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
