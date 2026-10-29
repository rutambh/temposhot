import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String themeModePreferenceKey = 'theme_mode';

/// Light, dark, or follow the device. Persisted locally so the chosen mode
/// survives a restart; preferences are a convenience only, so a failure to
/// read or write them leaves the app on the system default.
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system) {
    _restore();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(themeModePreferenceKey);
      final restored = switch (stored) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      if (mounted) state = restored;
    } catch (_) {
      // No preferences backend (tests, unsupported platform): keep system.
    }
  }

  Future<void> cycle() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    state = next;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(themeModePreferenceKey, next.name);
    } catch (_) {
      // The visible change already happened; persistence is best-effort.
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) {
    return ThemeModeController();
  },
);
