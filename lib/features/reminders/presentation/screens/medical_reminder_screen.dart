import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';
import 'package:flutter_period_tracker/shared/widgets/chip_groups.dart';
import 'package:flutter_period_tracker/shared/widgets/state_views.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/reminder.dart';
import '../providers/reminders_provider.dart';

extension ReminderTypeUi on ReminderType {
  String get label => switch (this) {
        ReminderType.pill => 'Fogamzásgátló',
        ReminderType.vitamin => 'Vitamin',
        ReminderType.medication => 'Gyógyszer',
      };

  IconData get icon => switch (this) {
        ReminderType.pill => Icons.medication_liquid_outlined,
        ReminderType.vitamin => Icons.health_and_safety_outlined,
        ReminderType.medication => Icons.medication_outlined,
      };
}

class MedicalReminderScreen extends ConsumerWidget {
  const MedicalReminderScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final reminder = await showDialog<Reminder>(
      context: context,
      builder: (_) => const _AddReminderDialog(),
    );
    if (reminder != null) {
      await ref.read(remindersProvider.notifier).add(reminder);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(remindersProvider);
    final notifier = ref.read(remindersProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Emlékeztetők')),
      body: reminders.when(
        loading: () => const LoadingView(),
        error: (e, _) => MessageView(
          icon: Icons.error_outline,
          message: 'Az emlékeztetők betöltése nem sikerült.',
          onRetry: () => ref.invalidate(remindersProvider),
        ),
        data: (list) => list.isEmpty
            ? const MessageView(
                icon: Icons.notifications_none,
                message: 'Még nincs emlékeztető.\nA + gombbal adhatsz hozzá.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final r = list[i];
                  return Dismissible(
                    key: ValueKey('reminder-${r.id}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => notifier.remove(r),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: context.colors.errorContainer,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(Icons.delete_outline,
                          color: context.colors.onErrorContainer),
                    ),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: context.colors.primaryContainer,
                          child: Icon(r.type.icon,
                              color: context.colors.onPrimaryContainer),
                        ),
                        title: Text(
                          r.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text('${r.type.label} · ${r.timeLabel}'),
                        trailing: Switch(
                          value: r.enabled,
                          onChanged: (v) => notifier.setEnabled(r, v),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Új emlékeztető',
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddReminderDialog extends StatefulWidget {
  const _AddReminderDialog();

  @override
  State<_AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<_AddReminderDialog> {
  final _title = TextEditingController();
  ReminderType _type = ReminderType.pill;
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final valid = _title.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Text('Új emlékeztető'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Név',
                hintText: 'Pl. D3-vitamin',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChipGroup<ReminderType>(
              options: ReminderType.values,
              selected: _type,
              labelOf: (t) => t.label,
              iconOf: (t) => t.icon,
              onChanged: (t) {
                if (t != null) setState(() => _type = t);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: Text(
                'Minden nap ${_time.hour.toString().padLeft(2, '0')}:'
                '${_time.minute.toString().padLeft(2, '0')}',
              ),
              onTap: _pickTime,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Mégse'),
        ),
        FilledButton(
          onPressed: valid
              ? () => Navigator.pop(
                    context,
                    Reminder(
                      type: _type,
                      title: _title.text.trim(),
                      hour: _time.hour,
                      minute: _time.minute,
                    ),
                  )
              : null,
          child: const Text('Mentés'),
        ),
      ],
    );
  }
}
