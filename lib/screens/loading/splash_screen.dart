import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../controllers/user_controller.dart'; // <-- Tambahkan import ini
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
    // Panggil _navigate tanpa Timer agar proses berjalan secepatnya
    _navigate();
  }

Future<void> _navigate() async {
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;

  try {
    final session = Get.find<UserSession>();
    final userController = Get.find<UserController>();

    if (session.userId.value.isNotEmpty) {
      print("Sesi ditemukan untuk user: ${session.userId.value}. Memuat data...");

      // Tambahkan timeout saat ambil user
      final user = await userController
          .getUserData(session.userId.value)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        print("Timeout saat memuat data pengguna.");
        return null;
      });

      if (user != null) {
        print("Data pengguna berhasil dimuat. Mengarahkan ke /home.");
        Get.offAllNamed('/home');
      } else {
        print("Gagal memuat data pengguna. Mengarahkan ke /login.");
        await session.clearSession();
        Get.offAllNamed('/login');
      }
    } else {
      print("Tidak ada sesi. Mengarahkan ke /login.");
      Get.offAllNamed('/login');
    }
  } catch (e) {
    print("Error saat navigasi splash: $e. Mengarahkan ke /login.");
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
            Image.asset('assets/img/Logo GrowME.png', width: 150),
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