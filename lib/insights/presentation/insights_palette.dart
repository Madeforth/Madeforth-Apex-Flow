import 'package:flutter/material.dart';

/// Named constants for the Insights screen's own "slate" visual language,
/// which is distinct from the app-wide [ApexColors] dark tokens (e.g. its
/// surface `0xFF1E293B` vs the token's `0xFF1F2937`) — close, but not the
/// same palette. Values are unchanged from what was previously scattered as
/// inline hex literals throughout `insights_screen.dart`; this file only
/// gives them one canonical name each so a future retint (or a decision to
/// unify with [ApexColors]) is a single edit instead of ~70. Scoped to this
/// feature rather than added to the global theme extension since nothing
/// outside Insights currently uses these.
abstract final class InsightsPalette {
  static const Color surface = Color(0xFF1E293B);
  static const Color surfaceDeep = Color(0xFF0F172A);
  static const Color border = Color(0xFF334155);
  static const Color mutedText = Color(0xFF94A3B8);

  static const Color caution = Color(0xFFEAB308);
  static const Color cautionBackground = Color(0xFF422006);

  static const Color danger = Color(0xFFef4444);
  static const Color dangerDeep = Color(0xFFdc2626);
  static const Color dangerBackground = Color(0xFF450a0a);

  static const Color successDeep = Color(0xFF059669);
  static const Color successBackground = Color(0xFF064e3b);

  // Second, visually distinct near-black sub-palette used by the OLED-style
  // cost-ledger sheet further down the same screen.
  static const Color oledBackground = Color(0xFF0A0A0A);
  static const Color oledBorder = Color(0xFF2D2D2F);
  static const Color oledMutedText = Color(0xFF9CA3AF);
}
