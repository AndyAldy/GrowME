import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../utils/user_session.dart';

class SplashScreen extends StatefulWidget {
  // Parameter untuk membedakan splash screen awal dan setelah login
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

void _navigate() {
  Timer(const Duration(seconds: 3), () {
    if (!mounted) return;

    if (widget.isPostAuth) {
      // Jika ini adalah splash screen setelah proses login/register,
      // pasti langsung ke halaman utama.
      Get.offAllNamed('/home');
      return; // Hentikan eksekusi lebih lanjut
    }

    // Dapatkan instance UserSession
    final session = Get.find<UserSession>();

    // Periksa apakah ada user ID yang tersimpan di sesi
    if (session.userId.value.isNotEmpty) {
      // Jika ADA sesi aktif, langsung arahkan ke HALAMAN UTAMA.
      // Data pengguna seharusnya sudah dimuat saat sesi diinisialisasi.
      print("Sesi ditemukan untuk user: ${session.userId.value}. Mengarahkan ke /home.");
      Get.offAllNamed('/home');
    } else {
      // Jika TIDAK ADA sesi, baru arahkan ke HALAMAN LOGIN.
      print("Tidak ada sesi. Mengarahkan ke /login.");
      Get.offAllNamed('/login');
    }
  });
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
              'Sabar..',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
