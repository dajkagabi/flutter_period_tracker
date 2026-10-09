import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';

/// Több elemet kiválasztó chip-csoport.
class MultiChipGroup<T> extends StatelessWidget {
  const MultiChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final List<T> options;
  final Set<T> selected;
  final String Function(T) labelOf;
  final ValueChanged<Set<T>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(labelOf(option)),
            selected: selected.contains(option),
            onSelected: (on) {
              final next = {...selected};
              on ? next.add(option) : next.remove(option);
              onChanged(next);
            },
          ),
      ],
    );
  }
}

/// Egy elemet kiválasztó chip-csoport (újrakattintással törölhető).
class SingleChipGroup<T> extends StatelessWidget {
  const SingleChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.enabled = true,
    this.iconOf,
  });

  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final IconData Function(T)? iconOf;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        for (final option in options)
          ChoiceChip(
            avatar: iconOf == null ? null : Icon(iconOf!(option), size: 18),
            label: Text(labelOf(option)),
            selected: selected == option,
            onSelected: enabled
                ? (on) => onChanged(on ? option : null)
                : null,
          ),
      ],
    );
  }
}
