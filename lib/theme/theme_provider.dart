import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeProvider extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  /// 1. Menjadikan variabel ini "observable" (reaktif) dengan `.obs`.
  ///    Ini berarti UI akan secara otomatis diperbarui ketika nilainya berubah.
  final RxBool isDarkMode = false.obs;

  /// 2. Getter untuk mendapatkan [ThemeMode] saat ini untuk [GetMaterialApp].
  ///    Ini menentukan apakah akan menggunakan tema terang atau gelap.
  ThemeMode get theme => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    // 3. Muat tema yang tersimpan saat aplikasi dimulai.
    _loadThemeFromBox();
  }

  /// Memuat preferensi tema dari [GetStorage].
  void _loadThemeFromBox() {
    isDarkMode.value = _box.read<bool>(_key) ?? false;
  }

  /// 4. Mengubah nilai tema dan menyimpannya ke [GetStorage].
  void toggleTheme() {
    // Ubah nilai boolean.
    isDarkMode.value = !isDarkMode.value;
    // Simpan nilai baru ke penyimpanan.
    _box.write(_key, isDarkMode.value);
    // Perbarui tema aplikasi secara visual.
    Get.changeThemeMode(theme);
  }
}