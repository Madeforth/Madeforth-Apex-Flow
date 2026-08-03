import 'package:apexflow/core/design/apex_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApexTypography Tests', () {
    test('Font families should be Geist and GeistMono', () {
      expect(ApexTypography.sans, 'Geist');
      expect(ApexTypography.mono, 'GeistMono');
    });

    test('telemetryHero should have correct configurations', () {
      final style = ApexTypography.telemetryHero(Colors.white);
      expect(style.fontFamily, 'Geist');
      expect(style.fontSize, 56);
      expect(style.height, 0.96);
      expect(style.letterSpacing, -1.1);
      expect(style.color, Colors.white);
    });

    test('technical should have correct configurations', () {
      final style = ApexTypography.technical(Colors.white);
      expect(style.fontFamily, 'GeistMono');
      expect(style.fontSize, 12);
      expect(style.height, 1.33);
      expect(style.color, Colors.white);
    });

    test('textTheme should generate correct styles under primary/secondary colors', () {
      const primaryColor = Colors.white;
      const secondaryColor = Colors.grey;

      final textTheme = ApexTypography.textTheme(
        primary: primaryColor,
        secondary: secondaryColor,
      );

      expect(textTheme.headlineLarge?.fontFamily, 'Geist');
      expect(textTheme.headlineLarge?.fontSize, 30);
      expect(textTheme.headlineLarge?.color, primaryColor);

      expect(textTheme.bodyMedium?.fontFamily, 'Geist');
      expect(textTheme.bodyMedium?.fontSize, 14);
      expect(textTheme.bodyMedium?.color, secondaryColor);
    });
  });
}
