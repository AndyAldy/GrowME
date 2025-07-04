// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_bindings.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'routes.dart';
import 'firebase_options.dart';

void main() async {
  // 1. Pastikan semua binding framework siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi service pihak ketiga
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Jalankan aplikasi
  runApp(const GrowME());
}

class GrowME extends StatelessWidget {
  const GrowME({super.key});

  @override
  Widget build(BuildContext context) {
    // ThemeProvider sudah di-handle oleh AppBindings, jadi kita bisa langsung find
    final themeProvider = Get.put(ThemeProvider());

    return GetMaterialApp(
      title: 'GrowME',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      // Cukup gunakan getter dari ThemeProvider
      themeMode: themeProvider.theme,

      // 4. Atur initialBinding ke AppBindings
      initialBinding: AppBindings(),

      // Rute awal Anda
      initialRoute: '/', // Pastikan rute ini ada di `appPages`
      getPages: appPages,
    );
  }
}