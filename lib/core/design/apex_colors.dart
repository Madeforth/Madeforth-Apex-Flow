import 'package:flutter/material.dart';
import 'package:apexflow/core/design/theme_extensions.dart';

abstract final class ApexColors {
  // Light theme — unchanged, not primary target
  static const ApexColorsExtension light = ApexColorsExtension(
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    elevated: Color(0xFFF1F3F5),
    border: Color(0xFFE9ECEF),
    cyan: Color(0xFF0E7490),
    red: Color(0xFFE11D48),
    white: Color(0xFF1F2937),
    textSecondary: Color(0xFF4B5563),
    muted: Color(0xFF9CA3AF),
    healthy: Color(0xFF10B981),
    caution: Color(0xFFF59E0B),
    orange: Color(0xFFFF5500),
    inkSoft: Color(0xFF374151),
    rail: Color(0xFFE5E7EB),
    onAccent: Color(0xFFFFFFFF),
    navChip: Color(0xFFFFFFFF),
  );

  // Dark theme — restored original colors
  static const ApexColorsExtension dark = ApexColorsExtension(
    background: Color(0xFF111827), // Original dark background
    surface: Color(0xFF1F2937), // Original dark surface
    elevated: Color(0xFF374151), // Original elevated card surface
    border: Color(0xFF4B5563), // Original border color
    cyan: Color(0xFF06B6D4), // Matte cyan
    red: Color(0xFFF43F5E), // Rose red
    white: Color(0xFFF5F5F5), // Slightly warm white for text
    textSecondary: Color(0xFF8E8E93), // iOS system secondary label
    muted: Color(0xFF636366), // iOS system tertiary label
    healthy: Color(0xFF34D399), // Emerald green
    caution: Color(0xFFFBBF24), // Amber
    orange: Color(0xFFFF7A33), // KTM orange — preserved
    inkSoft: Color(0xFFAEAEB2), // iOS system label
    rail: Color(0xFF1C1C1E), // Navigation rail background
    onAccent: Color(0xFF000000), // Black text on cyan backgrounds
    navChip: Color(0xFF1A1F2B), // Floating nav bar / fake tab-bar chip bg
  );
}
