// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/auth_controller.dart';
import '/controllers/user_controller.dart';
import '/theme/theme_provider.dart';
import '/widgets/nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil semua controller yang dibutuhkan menggunakan Get.find()
    final UserController userController = Get.find();
    final AuthController authController = Get.find();
    final ThemeProvider themeProvider = Get.find();

    return Scaffold(
      body: Obx(() { // Gunakan Obx untuk membuat UI reaktif terhadap perubahan data user
        final user = userController.user; // Ambil data user dari controller
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            Column(
              children: [
                // Header (Container dengan gradient)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, bottom: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary.withOpacity(0.7)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 50, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.name ?? 'Pengguna',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                // Switch untuk Fingerprint
                SwitchListTile(
                  title: const Text('Aktifkan Login dengan Fingerprint'),
                  secondary: const Icon(Icons.fingerprint),
                  value: user.fingerprintEnabled,
                  onChanged: (value) async {
                    // Panggil fungsi dari controller
                    await userController.updateFingerprintStatus(user.uid, value);
                  },
                ),
                const Divider(),
                // Switch untuk Tema
                Obx(() => SwitchListTile(
                      title: const Text('Tema Gelap'),
                      secondary: const Icon(Icons.dark_mode),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                      },
                    )),
                const Divider(),
              ],
            ),
            // Tombol Logout
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () {
                  // Panggil fungsi logout dari controller, lebih bersih!
                  authController.logout();
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Keluar',
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: const NavBar(currentIndex: 3),
    );
  }
}