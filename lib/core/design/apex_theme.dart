import 'package:apexflow/core/design/apex_colors.dart';
import 'package:apexflow/core/design/apex_spacing.dart';
import 'package:apexflow/core/design/apex_typography.dart';
import 'package:flutter/material.dart';

abstract final class ApexTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: false);
    final ext = ApexColors.light;

    return base.copyWith(
      scaffoldBackgroundColor: ext.background,
      colorScheme: ColorScheme.light(
        primary: ext.cyan,
        secondary: ext.orange,
        error: ext.red,
        surface: ext.surface,
        onSurface: ext.white,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: ext.orange,
        selectionColor: const Color(0x33FF5500),
        selectionHandleColor: ext.orange,
      ),
      textTheme: ApexTypography.textTheme(
        primary: ext.white,
        secondary: ext.textSecondary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ext.cyan,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: ext.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: ext.orange, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        surfaceTintColor: ext.surface,
        shadowColor: const Color(0x00000000),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: ext.background,
        foregroundColor: ext.white,
      ),
      extensions: [ext],
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: false);
    final ext = ApexColors.dark;

    return base.copyWith(
      scaffoldBackgroundColor: ext.background, // #000000
      colorScheme: ColorScheme.dark(
        primary: ext.cyan,
        secondary: ext.orange,
        error: ext.red,
        surface: ext.surface,
        onSurface: ext.white,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: ext.cyan,
        selectionColor: const Color(0x2206B6D4),
        selectionHandleColor: ext.cyan,
      ),
      textTheme: ApexTypography.textTheme(
        primary: ext.white,
        secondary: ext.textSecondary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ext.cyan,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      // Global input fields — flat dark, hairline border, cyan focus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.elevated, // #1C1C1E
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: ext.textSecondary, // #8E8E93
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: ext.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: ext.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: ext.cyan, width: 0.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: ext.red, width: 0.8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          borderSide: BorderSide(color: ext.red, width: 0.8),
        ),
        labelStyle: TextStyle(
          color: ext.textSecondary,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
        errorStyle: TextStyle(
          color: ext.red,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      // Navigation bar — pure black, no elevation
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: ext.background,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: ext.elevated,
      ),
      // AppBar — pure black, flat, hairline bottom divider handled per-screen
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: ext.background, // #000000
        foregroundColor: ext.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF5F5F5),
          letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: Color(0xFFF5F5F5), size: 22),
      ),
      // Cards — flat dark, hairline border, no shadow
      cardTheme: CardThemeData(
        elevation: 0,
        color: ext.elevated, // #1C1C1E
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          side: BorderSide(color: ext.border, width: 0.5),
        ),
      ),
      // Dialogs — dark, flat, hairline border
      dialogTheme: DialogThemeData(
        backgroundColor: ext.elevated, // #1C1C1E
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF5F5F5),
          letterSpacing: 0.2,
        ),
        contentTextStyle: TextStyle(
          fontSize: 13,
          color: const Color(0xFF8E8E93),
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          side: BorderSide(color: ext.border, width: 0.5),
        ),
      ),
      // Bottom sheets — dark, flat top border
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ext.elevated, // #1C1C1E
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        modalElevation: 0,
        modalBackgroundColor: ext.elevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(ApexSpacing.radius),
          ),
        ),
      ),
      // Snackbar — dark, subtle
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ext.elevated,
        contentTextStyle: const TextStyle(
          color: Color(0xFFF5F5F5),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          side: BorderSide(color: ext.border, width: 0.5),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      // Popup menu — dark, flat, hairline border
      popupMenuTheme: PopupMenuThemeData(
        color: ext.elevated, // #1C1C1E
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ApexSpacing.radius),
          side: BorderSide(color: ext.border, width: 0.5),
        ),
        textStyle: const TextStyle(
          color: Color(0xFFF5F5F5),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),
      // Dividers — hairline
      dividerTheme: DividerThemeData(
        color: ext.border, // #2D2D2F
        thickness: 0.5,
        space: 0,
      ),
      // Chips — flat
      chipTheme: ChipThemeData(
        backgroundColor: ext.elevated,
        side: BorderSide(color: ext.border, width: 0.5),
        labelStyle: TextStyle(
          color: ext.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        elevation: 0,
        pressElevation: 0,
      ),
      extensions: [ext],
    );
  }
}
