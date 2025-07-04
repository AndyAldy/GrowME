import 'package:GrowME/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '/controllers/auth_controller.dart';
import '/controllers/user_controller.dart';
import '/utils/user_session.dart';
import '../../theme/halus.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final RxBool passwordVisible = false.obs;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomPaint(
        painter: SmoothLinePainter(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/img/Logo_GrowME.png', height: 120),
                const SizedBox(height: 40),
                const BiometricLoginSection(),

                // Email Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(Icons.email, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password Field
                Obx(() => TextField(
                      controller: passwordController,
                      obscureText: !passwordVisible.value,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon:
                            const Icon(Icons.lock, color: Colors.white70),
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            passwordVisible.value = !passwordVisible.value;
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    )),
                const SizedBox(height: 30),

                // Tombol Login
                Obx(() => authController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          final user = await authController.signInWithEmail(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                          if (user != null) {
                            Get.offAllNamed('/home');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Login',
                            style: TextStyle(
                                fontSize: 18, color: Colors.white)),
                      )),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Get.toNamed('/register'),
                  child: const Text('Belum punya akun? Daftar sekarang',
                      style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// Widget terpisah untuk logika Biometrik agar lebih rapi
class BiometricLoginSection extends StatefulWidget {
  const BiometricLoginSection({super.key});

  @override
  State<BiometricLoginSection> createState() => _BiometricLoginSectionState();
}

class _BiometricLoginSectionState extends State<BiometricLoginSection> {
  final auth = LocalAuthentication();
  final session = Get.find<UserSession>();
  final userController = Get.find<UserController>();

  bool _isChecking = true;
  bool _showBiometric = false;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final args = Get.arguments;
    String? extractedUserId;

    if (args is Map && args['userId'] is String) {
      extractedUserId = args['userId'] as String;
    }

    final userId =
        session.userId.isNotEmpty ? session.userId.value : extractedUserId;

    if (userId == null || userId.isEmpty) {
      setState(() => _isChecking = false);
      return;
    }

    UserModel? user;
    try {
      user = await userController
          .getUserData(userId)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        print("[BIOMETRIK] Timeout");
        return null;
      });
    } catch (e) {
      print("[BIOMETRIK] Error getUserData: $e");
    }

    final canBiometric = await auth.canCheckBiometrics;

    if (mounted) {
      setState(() {
        _lastUserId = userId;
        _showBiometric = canBiometric && (user?.fingerprintEnabled ?? false);
        _isChecking = false;
      });
    }
  }

  Future<void> _authenticate() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Login dengan sidik jari',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated && _lastUserId != null) {
        await session.startSession(_lastUserId!);
        await userController.getUserData(_lastUserId!);
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Autentikasi sidik jari gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const SizedBox(
          height: 50, child: Center(child: CircularProgressIndicator()));
    }

    if (!_showBiometric) return const SizedBox.shrink();

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _authenticate,
          icon: const Icon(Icons.fingerprint),
          label: const Text("Login dengan Sidik Jari"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.withOpacity(0.8),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 20),
        const Text("atau", style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 20),
      ],
    );
  }
}
