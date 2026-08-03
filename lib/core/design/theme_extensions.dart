import 'package:flutter/material.dart';

class ApexColorsExtension extends ThemeExtension<ApexColorsExtension> {
  const ApexColorsExtension({
    required this.background,
    required this.surface,
    required this.elevated,
    required this.border,
    required this.cyan,
    required this.red,
    required this.white,
    required this.textSecondary,
    required this.muted,
    required this.healthy,
    required this.caution,
    required this.orange,
    required this.inkSoft,
    required this.rail,
    required this.onAccent,
  });

  final Color background;
  final Color surface;
  final Color elevated;
  final Color border;
  final Color cyan;
  final Color red;
  final Color white;
  final Color textSecondary;
  final Color muted;
  final Color healthy;
  final Color caution;
  final Color orange;
  final Color inkSoft;
  final Color rail;
  final Color onAccent;

  @override
  ApexColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? elevated,
    Color? border,
    Color? cyan,
    Color? red,
    Color? white,
    Color? textSecondary,
    Color? muted,
    Color? healthy,
    Color? caution,
    Color? orange,
    Color? inkSoft,
    Color? rail,
    Color? onAccent,
  }) {
    return ApexColorsExtension(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      elevated: elevated ?? this.elevated,
      border: border ?? this.border,
      cyan: cyan ?? this.cyan,
      red: red ?? this.red,
      white: white ?? this.white,
      textSecondary: textSecondary ?? this.textSecondary,
      muted: muted ?? this.muted,
      healthy: healthy ?? this.healthy,
      caution: caution ?? this.caution,
      orange: orange ?? this.orange,
      inkSoft: inkSoft ?? this.inkSoft,
      rail: rail ?? this.rail,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  ApexColorsExtension lerp(
    ThemeExtension<ApexColorsExtension>? other,
    double t,
  ) {
    if (other is! ApexColorsExtension) {
      return this;
    }
    return ApexColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      red: Color.lerp(red, other.red, t)!,
      white: Color.lerp(white, other.white, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      healthy: Color.lerp(healthy, other.healthy, t)!,
      caution: Color.lerp(caution, other.caution, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      rail: Color.lerp(rail, other.rail, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}

extension BuildContextColors on BuildContext {
  ApexColorsExtension get colors =>
      Theme.of(this).extension<ApexColorsExtension>()!;
}
