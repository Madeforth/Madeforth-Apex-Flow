import 'package:flutter/material.dart';

/// Named constants for a "slate" visual language used independently by the
/// Insights and Profile Hub screens, distinct from the app-wide
/// [ApexColorsExtension] dark tokens (e.g. this surface `0xFF1E293B` vs the
/// token's own surface `0xFF1F2937`) — close, but not the same palette.
/// Values are unchanged from what was previously scattered as inline hex
/// literals across both screens; this file only gives them one canonical
/// name each so a future retint (or a decision to unify with the app-wide
/// tokens) is a handful of edits instead of a hundred-plus. Kept as a
/// shared/ constant set (not folded into [ApexColorsExtension]) since it
/// represents a real, currently-distinct sub-palette rather than the
/// approved brand tokens.
abstract final class SlatePalette {
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

  // Second, visually distinct near-black sub-palette used by Insights'
  // OLED-style cost-ledger sheet.
  static const Color oledBackground = Color(0xFF0A0A0A);
  static const Color oledBorder = Color(0xFF2D2D2F);
  static const Color oledMutedText = Color(0xFF9CA3AF);
}
