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

class _GrowMEState extends State<GrowME> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      // Periksa apakah update tersedia
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        // Memulai "flexible update".
        // Ini akan menampilkan dialog dari Google Play dengan opsi "Nanti" dan "Update".
        await InAppUpdate.startFlexibleUpdate();
      }
    } catch (e) {
      print('Gagal melakukan pengecekan update: $e');
    }
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