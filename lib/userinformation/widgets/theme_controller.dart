import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeController extends ChangeNotifier {
  bool isDarkMode = false;

  ThemeController() {
    _loadThemePreference();
  }

  void toggleTheme() async {
    isDarkMode = !isDarkMode;
    notifyListeners();

    final box = await Hive.openBox('authBox');
    await box.put("isDarkMode", isDarkMode);
  }

  ThemeMode get currentTheme => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _loadThemePreference() async {
    final box = await Hive.openBox('authBox');
    isDarkMode = box.get("isDarkMode", defaultValue: false);
    notifyListeners();
  }
}
