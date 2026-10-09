import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
