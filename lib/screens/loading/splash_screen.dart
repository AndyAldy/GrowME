import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
// Pastikan path import ini benar dan menggunakan huruf kecil
import 'package:GrowME/firebase_options.dart';
import 'package:GrowME/controllers/user_controller.dart';
import 'package:GrowME/utils/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    print("[SPLASH] Memulai Splash");
    // Jeda singkat untuk menampilkan splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // FIX 1: Cek apakah ada argumen rute tujuan dari NavBar
    final String? destinationRoute = Get.arguments as String?;

    if (destinationRoute != null) {
      // Jika ADA argumen, berarti navigasi dari NavBar. Langsung ke tujuan.
      print("[SPLASH] Navigasi dari NavBar ke: $destinationRoute");
      // Gunakan offAllNamed agar tumpukan navigasi bersih
      Get.offAllNamed(destinationRoute);
      return; // Hentikan eksekusi lebih lanjut
    }

    // Jika TIDAK ADA argumen, lanjutkan logika pengecekan sesi (saat app pertama dibuka)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      final session = Get.find<UserSession>();
      final userController = Get.find<UserController>();

      if (session.userId.value.isNotEmpty) {
        print("[SPLASH] Mendeteksi sesi aktif. Mengambil data user...");

        // FIX 2: Hapus .timeout() yang tidak perlu.
        final user = await userController.getUserData(session.userId.value);

        if (user != null) {
          print("[SPLASH] Berhasil ambil user. Navigasi ke /home");
          Get.offAllNamed('/home');
        } else {
          print("[SPLASH] Sesi tidak valid. Redirect ke /login");
          await session.clearSession();
          Get.offAllNamed('/login');
        }
      } else {
        print("[SPLASH] Tidak ada sesi. Redirect ke /login");
        Get.offAllNamed('/login');
      }
    } catch (e, stack) {
      print("[SPLASH] ERROR saat navigate: $e");
      print(stack);
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/Logo_GrowME.png', width: 150),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}