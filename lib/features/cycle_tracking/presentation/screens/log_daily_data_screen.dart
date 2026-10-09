import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';
import 'package:flutter_period_tracker/core/utils/date_utils.dart';
import 'package:flutter_period_tracker/shared/widgets/chip_groups.dart';
import 'package:flutter_period_tracker/shared/widgets/section_header.dart';
import 'package:flutter_period_tracker/shared/widgets/state_views.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/daily_log.dart';
import '../labels.dart';
import '../providers/cycle_providers.dart';

class LogDailyDataScreen extends ConsumerStatefulWidget {
  const LogDailyDataScreen({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<LogDailyDataScreen> createState() => _LogDailyDataScreenState();
}

class _LogDailyDataScreenState extends ConsumerState<LogDailyDataScreen> {
  late final DateTime _date = dayOnly(widget.date);

  bool _loading = true;
  bool _hasExisting = false;
  bool _saving = false;

  bool _isPeriodStart = false;
  bool _isPeriodEnd = false;
  FlowIntensity? _flow;
  Set<Mood> _moods = {};
  Set<PhysicalSymptom> _physical = {};
  Set<SkinSymptom> _skin = {};
  Set<OtherSymptom> _other = {};
  bool _hadSex = false;
  ProtectionType? _protection;
  CervicalMucus? _mucus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs = await ref.read(dailyLogsProvider.future);
    if (!mounted) return;
    final existing = logs.where((l) => sameDay(l.date, _date)).firstOrNull;
    setState(() {
      if (existing != null) {
        _hasExisting = true;
        _isPeriodStart = existing.isPeriodStart;
        _isPeriodEnd = existing.isPeriodEnd;
        _flow = existing.flow;
        _moods = {...existing.moods};
        _physical = {...existing.physicalSymptoms};
        _skin = {...existing.skinSymptoms};
        _other = {...existing.otherSymptoms};
        _hadSex = existing.hadSexualActivity;
        _protection = existing.protection;
        _mucus = existing.cervicalMucus;
      }
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final log = DailyLog(
      date: _date,
      isPeriodStart: _isPeriodStart,
      isPeriodEnd: _isPeriodEnd,
      flow: _flow,
      moods: _moods,
      physicalSymptoms: _physical,
      skinSymptoms: _skin,
      otherSymptoms: _other,
      hadSexualActivity: _hadSex,
      protection: _hadSex ? _protection : null,
      cervicalMucus: _mucus,
    );
    try {
      await ref.read(dailyLogsProvider.notifier).save(log);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A mentés nem sikerült.')),
      );
    }
  }

  Future<void> _delete() async {
    await ref.read(dailyLogsProvider.notifier).delete(_date);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final title = DateFormat('yyyy. MMMM d.', 'hu_HU').format(_date);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _loading
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              children: [
                const SectionHeader('Menstruáció'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Menstruáció kezdete'),
                  value: _isPeriodStart,
                  onChanged: (v) => setState(() => _isPeriodStart = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Menstruáció vége'),
                  value: _isPeriodEnd,
                  onChanged: (v) => setState(() => _isPeriodEnd = v),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Vérzés erőssége', style: context.text.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                SingleChipGroup<FlowIntensity>(
                  options: FlowIntensity.values,
                  selected: _flow,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _flow = v),
                ),
                const SectionHeader('Hangulat'),
                MultiChipGroup<Mood>(
                  options: Mood.values,
                  selected: _moods,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _moods = v),
                ),
                const SectionHeader('Tünetek'),
                Text('Fizikai', style: context.text.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                MultiChipGroup<PhysicalSymptom>(
                  options: PhysicalSymptom.values,
                  selected: _physical,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _physical = v),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Bőr', style: context.text.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                MultiChipGroup<SkinSymptom>(
                  options: SkinSymptom.values,
                  selected: _skin,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _skin = v),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Egyéb', style: context.text.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                MultiChipGroup<OtherSymptom>(
                  options: OtherSymptom.values,
                  selected: _other,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _other = v),
                ),
                const SectionHeader('Szexuális aktivitás'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Volt szexuális aktivitás'),
                  value: _hadSex,
                  onChanged: (v) => setState(() => _hadSex = v),
                ),
                if (_hadSex)
                  SingleChipGroup<ProtectionType>(
                    options: ProtectionType.values,
                    selected: _protection,
                    labelOf: (v) => v.label,
                    onChanged: (v) => setState(() => _protection = v),
                  ),
                const SectionHeader('Ovuláció megfigyelés'),
                Text('Nyák típusa', style: context.text.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                SingleChipGroup<CervicalMucus>(
                  options: CervicalMucus.values,
                  selected: _mucus,
                  labelOf: (v) => v.label,
                  onChanged: (v) => setState(() => _mucus = v),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Mentés'),
                ),
                if (_hasExisting) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: _saving ? null : _delete,
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.error,
                    ),
                    child: const Text('Bejegyzés törlése'),
                  ),
                ],
              ],
            ),
    );
  }
}
