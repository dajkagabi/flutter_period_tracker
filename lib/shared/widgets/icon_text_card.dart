import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';

import 'app_card.dart';

/// Ikon + szöveg kártya (listaelemekhez, tanácsokhoz).
class IconTextCard extends StatelessWidget {
  const IconTextCard({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
  });

  final IconData icon;
  final String text;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md - 4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: iconColor ?? context.colors.primary),
            const SizedBox(width: AppSpacing.md - 4),
            Expanded(child: Text(text, style: context.text.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
