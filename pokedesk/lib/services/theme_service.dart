import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _key = 'isDarkMode';
  
  /// Notifica cambios de tema en tiempo real
  static final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  /// Inicializa el tema desde SharedPreferences
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_key) ?? false;
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggle entre light y dark mode
  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
    themeNotifier.value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool(_key, !isDarkMode);
  }

  /// Obtiene el modo actual
  static ThemeMode getThemeMode() => themeNotifier.value;

  /// Verifica si está en modo oscuro
  static bool isDarkMode() => themeNotifier.value == ThemeMode.dark;
}
