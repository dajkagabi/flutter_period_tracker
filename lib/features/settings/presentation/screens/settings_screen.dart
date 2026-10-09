import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';
import 'package:flutter_period_tracker/shared/widgets/section_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _dayOptions = [1, 2, 3, 5];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Beállítások')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          const SectionHeader('Értesítések'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Emlékeztető a menstruáció előtt'),
            subtitle: const Text('Értesítés a várható ciklus kezdete előtt'),
            value: settings.periodReminderEnabled,
            onChanged: notifier.setPeriodReminderEnabled,
          ),
          if (settings.periodReminderEnabled)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Emlékeztető ideje'),
              trailing: DropdownButton<int>(
                value: _dayOptions.contains(settings.daysBefore)
                    ? settings.daysBefore
                    : 2,
                items: [
                  for (final d in _dayOptions)
                    DropdownMenuItem(value: d, child: Text('$d nappal előtte')),
                ],
                onChanged: (v) {
                  if (v != null) notifier.setDaysBefore(v);
                },
              ),
            ),
          const SectionHeader('Adatvédelem'),
          Text(
            'A naplóbejegyzéseid ezen az eszközön tárolódnak. Az értesítések '
            'tartalma zárolt képernyőn nem jelenik meg.',
            style: context.text.bodyMedium,
          ),
        ],
      ),
    );
  }
}
