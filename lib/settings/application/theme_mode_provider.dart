import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    // Disabled: Always dark theme.
  }

  Future<void> toggleTheme(BuildContext context) async {
    // Disabled: Always dark theme.
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

final showThemeToggleProvider = StateProvider<bool>((ref) => false);
