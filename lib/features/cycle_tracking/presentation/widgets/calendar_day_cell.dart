import 'package:flutter/material.dart';
import 'package:flutter_period_tracker/app/theme/app_tokens.dart';

import '../../domain/cycle_analysis.dart';

extension DayMarkerColor on CycleColors {
  Color colorFor(DayMarker marker) => switch (marker) {
        DayMarker.period => period,
        DayMarker.predictedPeriod => predictedPeriod,
        DayMarker.ovulation => ovulation,
        DayMarker.fertile => fertile,
      };
}

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    this.marker,
    this.isSelected = false,
    this.isToday = false,
  });

  final DateTime day;
  final DayMarker? marker;
  final bool isSelected;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final background = marker == null
        ? null
        : context.cycleColors.colorFor(marker!);

    // A szövegszín a háttér világosságához igazodik (világos és sötét témában is olvasható).
    final textColor = background == null
        ? scheme.onSurface
        : (ThemeData.estimateBrightnessForColor(background) == Brightness.dark
            ? Colors.white
            : Colors.black87);

    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: scheme.primary, width: 2.5)
              : isToday
                  ? Border.all(color: scheme.outline, width: 1.5)
                  : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: (isSelected || isToday || background != null)
                ? FontWeight.w700
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
