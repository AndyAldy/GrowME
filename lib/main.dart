// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/chart_data_controller.dart'; // Jika Anda punya controller ini
import 'utils/user_session.dart';
import 'theme/theme_provider.dart'; 
import 'theme/app_theme.dart';
import 'routes.dart'; // Sesuaikan dengan path file routes Anda
import 'screens/loading/splash_screen.dart'; // Asumsi ada splash screen
import 'firebase_options.dart';

void main() async {
  // 1. Pastikan semua binding siap
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inisialisasi semua service yang dibutuhkan
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Panggil fungsi inisialisasi controller GetX
  initServices();

  runApp(const GrowME());
}

/// Inisialisasi semua service dan controller secara global dan permanen.
void initServices() {
  Get.put(ThemeProvider(), permanent: true);
  Get.put(UserSession(), permanent: true);
  Get.lazyPut(() => UserController(), fenix: true);
  Get.lazyPut(() => AuthController(), fenix: true);
  Get.lazyPut(() => ChartDataController(), fenix: true);
}

class GrowME extends StatelessWidget {
  const GrowME({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil ThemeProvider dari GetX
    final ThemeProvider themeProvider = Get.find();

    // Gunakan Obx untuk merebuild saat tema berubah
    return Obx(() => GetMaterialApp(
          title: 'GrowMe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,       // Sesuaikan dengan nama tema Anda
          darkTheme: AppTheme.darkTheme,     // Sesuaikan dengan nama tema Anda
          themeMode: themeProvider.themeMode,
          initialRoute: '/', // Selalu mulai dari splash screen
          getPages: appPages,             // Sesuaikan dengan nama routes Anda
        ));
  }
}