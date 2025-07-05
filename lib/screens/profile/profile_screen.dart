import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/auth_controller.dart';
import '/controllers/user_controller.dart';
import '/theme/app_theme.dart';
import '/theme/theme_provider.dart';
import '/widgets/nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil semua controller yang dibutuhkan
    final UserController userController = Get.find();
    final AuthController authController = Get.find();
    final ThemeProvider themeProvider = Get.find();

    // Gunakan Obx untuk merebuild UI saat data reaktif (user atau tema) berubah
    return Obx(() {
      // Ambil nilai boolean dari isDarkMode.value
      final isDark = themeProvider.isDarkMode.value;
      
      // Tentukan warna berdasarkan status tema
      final primaryColor = isDark ? AppTheme.darkTheme.colorScheme.primary : AppTheme.lightTheme.colorScheme.primary;
      final secondaryColor = isDark ? AppTheme.darkTheme.colorScheme.secondary : AppTheme.lightTheme.colorScheme.secondary;

      // Ambil data user dari user.value
      final user = userController.user.value;

      // Jika user masih loading, tampilkan indikator
      if (user == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // Jika user sudah ada, bangun UI utama
      return Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, bottom: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, secondaryColor.withOpacity(0.7)],
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
                        user.name,
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
                    await userController.updateFingerprintStatus(user.uid, value);
                  },
                ),
                const Divider(),
                // Switch untuk Tema
                SwitchListTile(
                  title: const Text('Tema Gelap'),
                  secondary: const Icon(Icons.dark_mode),
                  value: isDark,
                  onChanged: (value) {
                    // Cukup panggil toggleTheme, tidak perlu argumen
                    themeProvider.toggleTheme();
                  },
                ),
                const Divider(),
              ],
            ),
            // Tombol Logout
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () {
                  authController.logout();
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Keluar',
              ),
            ),
          ],
        ),
        bottomNavigationBar: const NavBar(currentIndex: 3),
      );
    });
  }
}
