import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan sesi login dan pilihan tema di penyimpanan lokal.
class Session {
  static const _kName = 'session_name';
  static const _kRole = 'session_role';
  static const _kTheme = 'theme_mode';

  /// Dipantau oleh MaterialApp supaya tema langsung berubah.
  static final ValueNotifier<ThemeMode> themeMode =
  ValueNotifier(ThemeMode.system);

  static Future<void> save({required String name, required String role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, name);
    await prefs.setString(_kRole, role);
  }

  /// Mengembalikan (nama, role) kalau ada sesi tersimpan, kalau tidak null.
  static Future<(String, String)?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kName);
    final role = prefs.getString(_kRole);
    if (name == null || role == null) return null;
    return (name, role);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kName);
    await prefs.remove(_kRole);
  }

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    themeMode.value = switch (prefs.getString(_kTheme)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static Future<void> setTheme(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }
}