import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>((ref) {
  return ThemeModeController(SharedPreferencesAsync());
});

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._preferences) : super(ThemeMode.system) {
    _load();
  }

  static const _themeModeKey = 'theme_mode';

  final SharedPreferencesAsync _preferences;

  Future<void> _load() async {
    final saved = await _preferences.getString(_themeModeKey);
    if (saved != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == saved,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _preferences.setString(_themeModeKey, mode.toString());
  }
}
