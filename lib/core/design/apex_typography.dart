import 'package:flutter/material.dart';

abstract final class ApexTypography {
  static const String sans = 'Geist';
  static const String mono = 'GeistMono';

  static const List<FontFeature> tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static TextStyle _sans({
    required double size,
    required double weight,
    required double height,
    required double tracking,
    required Color color,
    List<FontFeature>? features,
  }) {
    return TextStyle(
      fontFamily: sans,
      fontSize: size,
      height: height,
      letterSpacing: tracking,
      color: color,
      fontWeight: _semanticWeight(weight),
      fontVariations: <FontVariation>[
        FontVariation('wght', weight),
      ],
      fontFeatures: features,
    );
  }

  static FontWeight _semanticWeight(double weight) {
    if (weight >= 650) return FontWeight.w700;
    if (weight >= 600) return FontWeight.w600;
    if (weight >= 500) return FontWeight.w500;
    return FontWeight.w400;
  }

  static TextStyle telemetryHero(Color color) => _sans(
    size: 56,
    weight: 650,
    height: .96,
    tracking: -1.1,
    color: color,
    features: tabular,
  );

  static TextStyle technical(Color color) => TextStyle(
    fontFamily: mono,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
    fontVariations: const <FontVariation>[
      FontVariation('wght', 500),
    ],
    fontFeatures: tabular,
    color: color,
  );

  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
  }) {
    return TextTheme(
      headlineLarge: _sans(
        size: 30, weight: 650, height: 1.10,
        tracking: -.5, color: primary,
      ),
      headlineMedium: _sans(
        size: 24, weight: 600, height: 1.17,
        tracking: -.3, color: primary,
      ),
      titleLarge: _sans(
        size: 20, weight: 600, height: 1.20,
        tracking: -.2, color: primary,
      ),
      titleMedium: _sans(
        size: 17, weight: 600, height: 1.29,
        tracking: -.1, color: primary,
      ),
      bodyLarge: _sans(
        size: 16, weight: 400, height: 1.50,
        tracking: 0, color: primary,
      ),
      bodyMedium: _sans(
        size: 14, weight: 400, height: 1.43,
        tracking: 0, color: secondary,
      ),
      labelLarge: _sans(
        size: 15, weight: 600, height: 1.33,
        tracking: .1, color: primary,
      ),
      labelMedium: _sans(
        size: 12, weight: 500, height: 1.33,
        tracking: .3, color: secondary,
      ),
      bodySmall: _sans(
        size: 11, weight: 500, height: 1.36,
        tracking: .2, color: secondary,
      ),
    );
  }
}
