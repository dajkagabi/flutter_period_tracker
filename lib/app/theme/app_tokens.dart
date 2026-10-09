import 'package:flutter/material.dart';

/// Design tokenek: az új arculathoz elég ezt a fájlt (és az app_theme.dart-ot) cserélni.
abstract final class AppColors {
  /// Az egész ColorScheme ebből a színből generálódik.
  static const Color seed = Color(0xFFD94F7A);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
}

/// A ciklus-specifikus színek témához kötve (világos/sötét módban eltérőek).
@immutable
class CycleColors extends ThemeExtension<CycleColors> {
  const CycleColors({
    required this.period,
    required this.predictedPeriod,
    required this.ovulation,
    required this.fertile,
  });

  final Color period;
  final Color predictedPeriod;
  final Color ovulation;
  final Color fertile;

  static const light = CycleColors(
    period: Color(0xFFE57373),
    predictedPeriod: Color(0xFFCE93D8),
    ovulation: Color(0xFFFFB74D),
    fertile: Color(0xFF90CAF9),
  );

  static const dark = CycleColors(
    period: Color(0xFFEF9A9A),
    predictedPeriod: Color(0xFFBA68C8),
    ovulation: Color(0xFFFFCC80),
    fertile: Color(0xFF64B5F6),
  );

  @override
  CycleColors copyWith({
    Color? period,
    Color? predictedPeriod,
    Color? ovulation,
    Color? fertile,
  }) =>
      CycleColors(
        period: period ?? this.period,
        predictedPeriod: predictedPeriod ?? this.predictedPeriod,
        ovulation: ovulation ?? this.ovulation,
        fertile: fertile ?? this.fertile,
      );

  @override
  CycleColors lerp(ThemeExtension<CycleColors>? other, double t) {
    if (other is! CycleColors) return this;
    return CycleColors(
      period: Color.lerp(period, other.period, t)!,
      predictedPeriod: Color.lerp(predictedPeriod, other.predictedPeriod, t)!,
      ovulation: Color.lerp(ovulation, other.ovulation, t)!,
      fertile: Color.lerp(fertile, other.fertile, t)!,
    );
  }
}

extension ThemeContextX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  CycleColors get cycleColors => Theme.of(this).extension<CycleColors>()!;
}
