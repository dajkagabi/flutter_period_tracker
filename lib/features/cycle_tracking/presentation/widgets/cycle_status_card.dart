import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';
import 'package:flutter_period_tracker/shared/widgets/app_card.dart';
import 'package:intl/intl.dart';

import '../../domain/cycle_analysis.dart';
import '../labels.dart';

/// A kiválasztott nap ciklus-állapota: ciklusnap, fázis, következő menstruáció.
class CycleStatusCard extends StatelessWidget {
  const CycleStatusCard({
    super.key,
    required this.status,
    required this.isToday,
  });

  final CycleStatus? status;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final s = status;
    if (s == null) {
      return AppCard(
        child: Row(
          children: [
            Icon(Icons.edit_calendar_outlined, color: context.colors.primary),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Text(
                'Még nincs elég adat. Naplózd a legutóbbi menstruációd első '
                'napját, és megjelennek a becslések.',
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('yyyy. MMMM d.', 'hu_HU');
    final next = dateFormat.format(s.nextPeriodStart);
    final String nextText;
    if (!isToday) {
      nextText = '${s.isPrediction ? 'Várható' : 'Következő'} menstruáció: $next';
    } else if (s.daysUntilNextPeriod > 0) {
      nextText = 'Következő menstruáció (becslés): $next · ${s.daysUntilNextPeriod} nap múlva';
    } else if (s.daysUntilNextPeriod == 0) {
      nextText = 'A becslés szerint ma kezdődik a menstruációd';
    } else {
      nextText = 'A becsült kezdethez képest ${-s.daysUntilNextPeriod} napot késik';
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(s.phase.icon, color: context.colors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${s.cycleDay}. ciklusnap · ${s.phase.shortLabel}',
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(nextText, style: context.text.bodyMedium),
        ],
      ),
    );
  }
}
