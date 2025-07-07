// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:in_app_update/in_app_update.dart';
import 'app_bindings.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import 'firebase_options.dart';
import 'package:flutter/scheduler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GrowME());
}

class GrowME extends StatefulWidget {
  const GrowME({super.key});

  @override
  State<GrowME> createState() => _GrowMEState();
}

// DIUBAH: Tambahkan 'with WidgetsBindingObserver'
class _GrowMEState extends State<GrowME> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Daftarkan observer untuk mendengarkan siklus hidup aplikasi
    WidgetsBinding.instance.addObserver(this);
    
    // Panggil pengecekan update setelah frame pertama selesai
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  @override
  void dispose() {
    // Hapus observer untuk mencegah kebocoran memori
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // BARU: Method ini akan berjalan setiap kali pengguna kembali ke aplikasi
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Periksa apakah ada update yang sudah terunduh dan siap diinstal
      _promptToInstallUpdate();
    }
  }

  // Langkah 1: Memeriksa dan memulai unduhan update
  Future<void> _checkForUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Mulai unduhan di latar belakang
        await InAppUpdate.startFlexibleUpdate();
        // Langsung cek, karena update kecil bisa selesai sangat cepat
        _promptToInstallUpdate();
      }
    } catch (e) {
      print('Gagal memulai pengecekan update: $e');
    }
  }
  
  // BARU: Langkah 2: Memeriksa dan memicu instalasi
  Future<void> _promptToInstallUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      // Jika statusnya DOWNLOADED, artinya siap diinstal
      if (updateInfo.installStatus == InstallStatus.downloaded) {
        // Tampilkan notifikasi untuk mengajak user me-restart
        _showInstallSnackbar();
      }
    } catch (e) {
      print('Gagal memeriksa status instalasi: $e');
    }
  }
  
  // BARU: Menampilkan notifikasi/snackbar untuk restart
  void _showInstallSnackbar() {
    Get.snackbar(
      "Update Telah Terunduh",
      "Restart aplikasi untuk menginstal versi baru.",
      duration: const Duration(days: 1), // Dibuat persisten
      isDismissible: false,
      mainButton: TextButton(
        child: const Text('RESTART SEKARANG'),
        onPressed: () {
          // KUNCI UTAMA: Memanggil fungsi untuk menginstal update
          InAppUpdate.completeFlexibleUpdate();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Get.put(ThemeProvider());

    return GetMaterialApp(
      title: 'GrowME',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.theme,
      initialBinding: AppBindings(),
      initialRoute: '/',
      getPages: appPages,
    );
  }
}