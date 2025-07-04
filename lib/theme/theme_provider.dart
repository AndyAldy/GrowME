import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeProvider extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // 1. Jadikan variabel ini "observable" (reaktif) dengan .obs
  final isDarkMode = false.obs;

  // 2. Getter untuk mendapatkan ThemeMode saat ini untuk GetMaterialApp
  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    // 3. Muat tema yang tersimpan saat aplikasi dimulai
    _loadThemeFromBox();
  }

  // Method untuk memuat preferensi tema dari penyimpanan
  void _loadThemeFromBox() {
    isDarkMode.value = _box.read(_key) ?? false;
  }

  // 4. Method untuk mengubah tema menjadi lebih sederhana
  void toggleTheme() {
    // Ubah nilai boolean
    isDarkMode.value = !isDarkMode.value;
    // Simpan nilai baru ke penyimpanan
    _box.write(_key, isDarkMode.value);
  }
}
