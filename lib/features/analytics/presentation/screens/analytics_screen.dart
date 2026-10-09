import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/domain/daily_log.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/presentation/labels.dart';
import 'package:flutter_period_tracker/shared/widgets/app_card.dart';
import 'package:flutter_period_tracker/shared/widgets/section_header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Elemzések')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.autorenew,
                  title: 'Átlagos ciklus',
                  value: data.hasCycleLengthData
                      ? '${data.averageCycleLength} nap'
                      : '—',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  icon: Icons.water_drop_outlined,
                  title: 'Átlagos vérzés',
                  value: data.hasPeriodLengthData
                      ? '${data.averagePeriodLength} nap'
                      : '—',
                ),
              ),
            ],
          ),
          if (!data.hasCycleLengthData) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Text(
                'Az elemzésekhez legalább két menstruáció kezdetét naplózd. '
                'Addig nem mutatunk kitalált számokat.',
                style: context.text.bodyMedium,
              ),
            ),
          ],
          if (data.cycleLengthRange > 7) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Text(
                'A ciklusaid hossza között ${data.cycleLengthRange} nap a különbség. '
                'Ha ez gyakori, érdemes orvossal megbeszélni.',
                style: context.text.bodyMedium,
              ),
            ),
          ],
          if (data.hasCycleLengthData) ...[
            const SectionHeader('Ciklushossz alakulása'),
            _CycleLengthChart(lengths: data.cycleLengths),
          ],
          if (data.flowCounts.isNotEmpty) ...[
            const SectionHeader('Vérzés erőssége'),
            _FlowChart(counts: data.flowCounts),
          ],
          if (data.symptomCounts.isNotEmpty) ...[
            const SectionHeader('Gyakori fizikai tünetek'),
            _SymptomBars(entries: data.symptomCounts.take(6).toList()),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Icon(icon, color: context.colors.primary, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: context.text.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CycleLengthChart extends StatelessWidget {
  const _CycleLengthChart({required this.lengths});
  final List<int> lengths;

  @override
  Widget build(BuildContext context) {
    // Az utolsó 12 ciklus.
    final shown =
        lengths.length > 12 ? lengths.sublist(lengths.length - 12) : lengths;
    final maxValue = shown.reduce((a, b) => a > b ? a : b);
    final color = context.cycleColors.predictedPeriod;
    const noTitles = AxisTitles(sideTitles: SideTitles(showTitles: false));

    return AppCard(
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            minY: 0,
            maxY: (maxValue + 5).toDouble(),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              topTitles: noTitles,
              rightTitles: noTitles,
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: 7,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: context.text.labelSmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= shown.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${i + 1}.',
                        style: context.text.labelSmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < shown.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: shown[i].toDouble(),
                      color: color,
                      width: 18,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowChart extends StatelessWidget {
  const _FlowChart({required this.counts});
  final Map<FlowIntensity, int> counts;

  @override
  Widget build(BuildContext context) {
    final base = context.cycleColors.period;
    final colors = {
      FlowIntensity.light: Color.lerp(base, Colors.white, 0.4)!,
      FlowIntensity.medium: base,
      FlowIntensity.heavy: Color.lerp(base, Colors.black, 0.35)!,
    };

    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 28,
                sections: [
                  for (final e in counts.entries)
                    PieChartSectionData(
                      value: e.value.toDouble(),
                      color: colors[e.key],
                      radius: 38,
                      showTitle: false,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in counts.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[e.key],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('${e.key.label}: ${e.value} nap'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomBars extends StatelessWidget {
  const _SymptomBars({required this.entries});
  final List<MapEntry<PhysicalSymptom, int>> entries;

  @override
  Widget build(BuildContext context) {
    final maxCount = entries.first.value;
    return AppCard(
      child: Column(
        children: [
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(e.key.label, style: context.text.bodyMedium),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: LinearProgressIndicator(
                        value: e.value / maxCount,
                        minHeight: 10,
                        color: context.cycleColors.period,
                        backgroundColor: context.colors.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${e.value}',
                      textAlign: TextAlign.end,
                      style: context.text.labelLarge,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
