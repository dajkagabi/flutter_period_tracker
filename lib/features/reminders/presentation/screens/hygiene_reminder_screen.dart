import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';
import 'package:flutter_period_tracker/shared/widgets/app_card.dart';
import 'package:flutter_period_tracker/shared/widgets/chip_groups.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/hygiene_product.dart';
import '../providers/hygiene_timer_provider.dart';

extension HygieneProductUi on HygieneProduct {
  String get label => switch (this) {
        HygieneProduct.pad => 'Betét',
        HygieneProduct.reusablePad => 'Mosható betét',
        HygieneProduct.periodUnderwear => 'Menstruációs bugyi',
        HygieneProduct.tampon => 'Tampon',
        HygieneProduct.cup => 'Kehely',
        HygieneProduct.disc => 'Korong',
      };

  IconData get icon => switch (this) {
        HygieneProduct.pad || HygieneProduct.reusablePad => Icons.crop_square,
        HygieneProduct.periodUnderwear => Icons.checkroom,
        HygieneProduct.tampon => Icons.water_drop_outlined,
        HygieneProduct.cup || HygieneProduct.disc => Icons.local_cafe_outlined,
      };
}

class HygieneReminderScreen extends ConsumerStatefulWidget {
  const HygieneReminderScreen({super.key});

  @override
  ConsumerState<HygieneReminderScreen> createState() =>
      _HygieneReminderScreenState();
}

class _HygieneReminderScreenState extends ConsumerState<HygieneReminderScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Csak a kijelzőt frissíti; az időzítő állapota a lejárati időpont.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && ref.read(hygieneTimerProvider).isActive) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hygieneTimerProvider);
    final notifier = ref.read(hygieneTimerProvider.notifier);
    final remaining = state.remaining(DateTime.now());
    final expired = state.isActive && remaining == Duration.zero;

    final String caption;
    if (expired) {
      caption = 'Lejárt az idő – ideje cserélni vagy tisztítani.';
    } else if (state.isActive) {
      caption = 'A következő cseréig / tisztításig';
    } else {
      caption = 'Ajánlott időtartam (${state.product.label})';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Higiéniai időzítő')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Válassz eszközt', style: context.text.titleSmall),
                  const SizedBox(height: AppSpacing.md - 4),
                  SingleChipGroup<HygieneProduct>(
                    options: HygieneProduct.values,
                    selected: state.product,
                    enabled: !state.isActive,
                    labelOf: (p) => p.label,
                    iconOf: (p) => p.icon,
                    onChanged: (p) {
                      if (p != null) notifier.selectProduct(p);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _format(remaining),
                      style: context.text.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: expired ? context.colors.error : null,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      caption,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium
                          ?.copyWith(color: context.colors.outline),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              'Az időtartam általános ajánlás. Kövesd a termék használati '
              'útmutatóját, és ne lépd túl a gyártó által megadott maximális '
              'viselési időt.',
              style: context.text.bodySmall?.copyWith(color: context.colors.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            if (state.isActive)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(88, 52),
                      ),
                      onPressed: notifier.stop,
                      child: const Text('Leállítás'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md - 4),
                  Expanded(
                    child: FilledButton(
                      onPressed: notifier.start,
                      child: const Text('Újraindítás'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: notifier.start,
                  child: const Text('Időzítő indítása'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
