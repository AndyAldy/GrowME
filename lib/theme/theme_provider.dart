import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeProvider extends GetxController {
  final _box = GetStorage();
  ThemeMode themeMode = ThemeMode.light;

  ThemeProvider() {
    final savedTheme = _box.read('themeMode') ?? 'light';
    themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _box.write('themeMode', isOn ? 'dark' : 'light');
    update(); // ini milik GetxController, bukan notifyListeners
  }
}
