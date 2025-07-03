  import 'package:flutter/material.dart';
  import 'package:get_storage/get_storage.dart';

  class ThemeProvider extends ChangeNotifier {
    final _box = GetStorage();
    ThemeMode _themeMode = ThemeMode.light;

    ThemeProvider() {
      final savedTheme = _box.read('themeMode') ?? 'light';
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }

    ThemeMode get themeMode => _themeMode;

    bool get isDarkMode => _themeMode == ThemeMode.dark;

    void toggleTheme(bool isOn) {
      _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
      _box.write('themeMode', isOn ? 'dark' : 'light');
      notifyListeners();
    }
  }