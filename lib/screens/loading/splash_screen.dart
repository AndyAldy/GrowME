import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';

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

// lib/screens/loading/splash_screen.dart

Future<void> _navigate() async {
  // Jeda untuk menampilkan logo
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;
  final storage = GetStorage();
  final lastUserId = storage.read<String>('userId'); // Gunakan kunci yang sama dengan di UserSession

  print("[SPLASH] Mengarahkan ke login dengan User ID: $lastUserId");
  
  Get.offAllNamed(
    '/login',
    // Kirimkan userId yang dibaca langsung dari penyimpanan
    arguments: {'userId': lastUserId ?? ''},
  );
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