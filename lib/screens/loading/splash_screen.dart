import 'package:GrowME/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../controllers/user_controller.dart';
import '../../utils/user_session.dart';

class SplashScreen extends StatefulWidget {
  final bool isPostAuth;

  const SplashScreen({super.key, this.isPostAuth = false});

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
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) {
    print("[SPLASH] Widget tidak mounted, keluar");
    return;
  }

  try {
    if (Firebase.apps.isEmpty) {
      print("[SPLASH] Firebase belum siap, inisialisasi...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      print("[SPLASH] Firebase sudah siap");
    }

    final session = Get.find<UserSession>();
    final userController = Get.find<UserController>();

    print("[SPLASH] userId dari session: ${session.userId.value}");

    if (session.userId.value.isNotEmpty) {
      print("[SPLASH] Mendeteksi userId aktif. Mengambil data user...");
      final user = await userController
          .getUserData(session.userId.value)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        print("[SPLASH] Timeout ambil data user");
        return null;
      });

      if (user != null) {
        print("[SPLASH] Berhasil ambil user. Navigasi ke /home");
        Get.offAllNamed('/home');
      } else {
        print("[SPLASH] user NULL, redirect ke /login");
        await session.clearSession();
        Get.offAllNamed('/login');
      }
    } else {
      print("[SPLASH] Tidak ada sesi userId. Redirect ke /login");
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/Logo_GrowME.png', width: 150),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Menyiapkan data...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
