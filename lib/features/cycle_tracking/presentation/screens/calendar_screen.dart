import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/routes.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';
import 'package:flutter_period_tracker/core/providers.dart';
import 'package:flutter_period_tracker/core/utils/date_utils.dart';
import 'package:flutter_period_tracker/features/lifestyle/presentation/screens/lifestyle_screen.dart';
import 'package:flutter_period_tracker/shared/widgets/app_card.dart';
import 'package:flutter_period_tracker/shared/widgets/state_views.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/cycle_analysis.dart';
import '../providers/cycle_providers.dart';
import '../widgets/calendar_day_cell.dart';
import '../widgets/cycle_status_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = currentDay();
  DateTime _selectedDay = currentDay();
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(dailyLogsProvider);
    final today = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cikluskövető'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Elemzések',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.analytics),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Beállítások',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: logs.when(
        loading: () => const LoadingView(),
        error: (error, _) => MessageView(
          icon: Icons.error_outline,
          message: 'Az adatok betöltése nem sikerült.',
          onRetry: () => ref.invalidate(dailyLogsProvider),
        ),
        data: (_) => _buildContent(context, today),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.edit_note),
            label: Text(
              'Naplózás · ${DateFormat('yyyy. MM. dd.', 'hu_HU').format(_selectedDay)}',
            ),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.log,
              arguments: _selectedDay,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DateTime today) {
    final markers = ref.watch(calendarMarkersProvider);
    final status = ref.watch(cycleStatusProvider(_selectedDay));
    final cycle = context.cycleColors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      children: [
        TableCalendar<void>(
          locale: 'hu_HU',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2035, 12, 31),
          focusedDay: _focusedDay,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: _format,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Hónap',
            CalendarFormat.twoWeeks: '2 hét',
            CalendarFormat.week: 'Hét',
          },
          selectedDayPredicate: (day) => sameDay(day, _selectedDay),
          onDaySelected: (selected, focused) => setState(() {
            _selectedDay = dayOnly(selected);
            _focusedDay = focused;
          }),
          onFormatChanged: (format) => setState(() => _format = format),
          // Lapozáskor nincs adatbetöltés, csak a fókusz változik.
          onPageChanged: (focused) => _focusedDay = focused,
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, _) => CalendarDayCell(
              day: day,
              marker: markers[dayOnly(day)],
            ),
            todayBuilder: (context, day, _) => CalendarDayCell(
              day: day,
              marker: markers[dayOnly(day)],
              isToday: true,
            ),
            selectedBuilder: (context, day, _) => CalendarDayCell(
              day: day,
              marker: markers[dayOnly(day)],
              isSelected: true,
              isToday: sameDay(day, today),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _Legend(cycle: cycle),
        const SizedBox(height: AppSpacing.md),
        CycleStatusCard(status: status, isToday: sameDay(_selectedDay, today)),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.self_improvement,
                label: 'Életmód',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.lifestyle,
                  arguments: LifestyleArgs(phase: status?.phase),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ActionTile(
                icon: Icons.notifications_active_outlined,
                label: 'Emlékeztetők',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.medicalReminders),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ActionTile(
                icon: Icons.timer_outlined,
                label: 'Higiéniai időzítő',
                onTap: () => Navigator.pushNamed(context, AppRoutes.hygiene),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'A termékeny időszak és az ovuláció becslés, nem fogamzásgátló módszer.',
          style: context.text.bodySmall?.copyWith(color: context.colors.outline),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.cycle});
  final CycleColors cycle;

  @override
  Widget build(BuildContext context) {
    Widget item(DayMarker marker, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: cycle.colorFor(marker),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: context.text.bodySmall),
          ],
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: [
          item(DayMarker.period, 'Menstruáció'),
          item(DayMarker.predictedPeriod, 'Várható menstruáció'),
          item(DayMarker.ovulation, 'Becsült ovuláció'),
          item(DayMarker.fertile, 'Becsült termékeny időszak'),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Icon(icon, color: context.colors.primary, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: context.text.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
