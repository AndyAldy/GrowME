import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Tambahkan 'with SingleTickerProviderStateMixin' untuk animasi
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  // Deklarasikan controller dan animasi
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // Durasi satu siklus (membesar lalu mengecil)
      vsync: this,
    )..repeat(reverse: true); // Membuat animasi berulang dan bolak-balik

    // Inisialisasi Animasi dengan Tween (menentukan rentang nilai)
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Membuat gerakan lebih halus di awal dan akhir
      ),
    );

    // Tetap panggil fungsi navigasi Anda
    _navigate();
  }

  // JANGAN LUPA untuk membuang controller saat widget tidak digunakan
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fungsi navigasi Anda TIDAK PERLU DIUBAH
  Future<void> _navigate() async {
    // Jeda untuk menampilkan logo
    await Future.delayed(const Duration(seconds: 4)); // Mungkin perlu diperpanjang agar animasi terlihat

    if (!mounted) return;
    final storage = GetStorage();
    final lastUserId = storage.read<String>('userId');

    print("[SPLASH] Mengarahkan ke login dengan User ID: $lastUserId");

    Get.offAllNamed(
      '/login',
      arguments: {'userId': lastUserId ?? ''},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bungkus gambar dengan ScaleTransition
            ScaleTransition(
              scale: _animation, // Terapkan animasi skala
              child: Image.asset('assets/img/Logo_GrowME.png', width: 150),
            ),
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