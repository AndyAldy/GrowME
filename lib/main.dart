import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:growmee/controllers/auth_controller.dart';
import 'package:growmee/controllers/chart_data_controller.dart';
import 'package:growmee/controllers/user_controller.dart';
import 'package:growmee/firebase_options.dart';
import 'package:growmee/routes.dart';
import 'package:growmee/theme/app_theme.dart';
import 'package:growmee/theme/theme_provider.dart';
import 'package:growmee/utils/user_session.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 1. Pastikan binding siap. Ini harus selalu jadi yang pertama.
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Muat semua service yang dibutuhkan & AWAIT semuanya.
  await dotenv.load(fileName: ".env");

  await GetStorage.init();

  // 3. Inisialisasi controller utama menggunakan GetX.
  Get.put(UserSession(), permanent: true);
  Get.put(ChartDataController(), permanent: true);

  // 5. Jalankan aplikasi dengan MultiProvider.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // UserController bergantung pada UserSession, jadi lebih baik diinisialisasi di sini.
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (__) => AuthController()),
      ],
      child: const GrowME(), // Widget root aplikasi kita
    ),
  );
}

class GrowME extends StatelessWidget {
  const GrowME({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer sekarang bisa mengakses ThemeProvider dengan aman.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GetMaterialApp(
          title: 'GrowMe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/', // Selalu mulai dari splash screen
          getPages: appPages,
        );
      },
    );
  }
}