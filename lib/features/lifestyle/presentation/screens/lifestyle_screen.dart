import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/domain/cycle_phase.dart';
import 'package:flutter_period_tracker/features/cycle_tracking/presentation/labels.dart';
import 'package:flutter_period_tracker/shared/widgets/app_card.dart';
import 'package:flutter_period_tracker/shared/widgets/icon_text_card.dart';
import 'package:flutter_period_tracker/shared/widgets/section_header.dart';

import '../../domain/phase_content.dart';

enum LifestyleCategory {
  fitness('Mozgás', Icons.directions_run),
  nutrition('Étrend', Icons.restaurant_menu),
  mental('Mentális', Icons.self_improvement),
  skincare('Bőrápolás', Icons.face_retouching_natural),
  sleep('Alvás', Icons.bedtime_outlined);

  const LifestyleCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class LifestyleArgs {
  const LifestyleArgs({this.phase, this.category = LifestyleCategory.fitness});

  /// Az aktuális fázis; ha nem ismert (még nincs adat), a follikuláris a kezdőérték.
  final CyclePhase? phase;
  final LifestyleCategory category;
}

/// Az öt korábbi életmód-képernyő helyett egyetlen, füles képernyő.
class LifestyleScreen extends StatefulWidget {
  const LifestyleScreen({super.key, this.args = const LifestyleArgs()});

  final LifestyleArgs args;

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  late CyclePhase _phase = widget.args.phase ?? CyclePhase.follicular;

  @override
  Widget build(BuildContext context) {
    final content = PhaseContents.of(_phase);

    return DefaultTabController(
      length: LifestyleCategory.values.length,
      initialIndex: widget.args.category.index,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Életmód & ajánlások'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final c in LifestyleCategory.values)
                Tab(icon: Icon(c.icon), text: c.label),
            ],
          ),
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  for (final p in CyclePhase.values)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        avatar: Icon(p.icon, size: 18),
                        label: Text(p.shortLabel),
                        selected: p == _phase,
                        onSelected: (_) => setState(() => _phase = p),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (final c in LifestyleCategory.values)
                    _CategoryPage(content: content, category: c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPage extends StatelessWidget {
  const _CategoryPage({required this.content, required this.category});

  final PhaseContent content;
  final LifestyleCategory category;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      children: [
        AppCard(
          color: context.colors.primaryContainer.withValues(alpha: 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.title,
                style: context.text.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(content.description, style: context.text.bodyMedium),
              const Divider(height: AppSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.science_outlined,
                      size: 18, color: context.colors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Hormonális állapot: ${content.hormoneOverview}',
                      style: context.text.bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ..._sections(context),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Általános tájékoztatás, nem helyettesíti az orvosi tanácsot.',
          style: context.text.bodySmall?.copyWith(color: context.colors.outline),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _sections(BuildContext context) {
    final c = context.colors;

    Widget bullets(List<String> items, IconData icon, Color color) => Column(
          children: [
            for (final item in items)
              IconTextCard(icon: icon, text: item, iconColor: color),
          ],
        );

    return switch (category) {
      LifestyleCategory.fitness => [
          const SectionHeader('Ajánlott intenzitás'),
          IconTextCard(
              icon: Icons.speed, text: content.intensityGuide, iconColor: c.tertiary),
          const SectionHeader('Ajánlott mozgásformák'),
          bullets(content.recommendedWorkouts, Icons.check_circle_outline, c.primary),
          if (content.workoutsToAvoid.isNotEmpty) ...[
            const SectionHeader('Mérséklendő / kímélendő'),
            bullets(content.workoutsToAvoid, Icons.warning_amber_rounded, c.error),
          ],
        ],
      LifestyleCategory.nutrition => [
          const SectionHeader('Hidratáció'),
          IconTextCard(
              icon: Icons.water_drop_outlined,
              text: content.hydrationAdvice,
              iconColor: c.tertiary),
          const SectionHeader('Javasolt ételek & alapanyagok'),
          bullets(content.recommendedFoods, Icons.restaurant_menu, c.primary),
          const SectionHeader('Kiemelt tápanyagok'),
          bullets(content.keyNutrients, Icons.grain, c.secondary),
        ],
      LifestyleCategory.mental => [
          const SectionHeader('Feltöltődés & stresszkezelés'),
          bullets(content.mentalWellnessTips, Icons.self_improvement, c.primary),
          const SectionHeader('Társas energia'),
          IconTextCard(
              icon: Icons.people_outline,
              text: content.socialEnergy,
              iconColor: c.tertiary),
        ],
      LifestyleCategory.skincare => [
          const SectionHeader('A bőr állapota'),
          IconTextCard(
              icon: Icons.face_outlined,
              text: content.skinState,
              iconColor: c.tertiary),
          const SectionHeader('Bőrápolási tippek'),
          bullets(content.skincareTips, Icons.clean_hands_outlined, c.primary),
        ],
      LifestyleCategory.sleep => [
          const SectionHeader('Energiaszint'),
          IconTextCard(
              icon: Icons.bolt_outlined,
              text: content.energyLevel,
              iconColor: c.tertiary),
          const SectionHeader('Alvási tanácsok'),
          IconTextCard(
              icon: Icons.bedtime_outlined,
              text: content.sleepAdvice,
              iconColor: c.primary),
          const SectionHeader('Vitaminok & kiegészítők'),
          bullets(content.vitaminsAndSupplements, Icons.medication_outlined, c.secondary),
        ],
    };
  }
}
