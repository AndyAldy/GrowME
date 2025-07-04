import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '/controllers/auth_controller.dart';
import '/controllers/user_controller.dart';
import '/utils/user_session.dart';
import '../../theme/halus.dart'; // Sesuaikan path jika perlu

// 1. Ubah menjadi StatelessWidget
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Pindahkan semua controller dan variabel ke dalam build method agar lebih rapi
    final AuthController authController = Get.find();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    
    // Gunakan RxBool untuk state lokal yang simpel seperti password visibility
    final RxBool passwordVisible = false.obs;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomPaint(
        painter: SmoothLinePainter(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/GrowME.png',
                  height: 120,
                ),
                const SizedBox(height: 40),
                // Untuk biometrik, kita bisa buat widget terpisah agar lebih clean
                const BiometricLoginSection(),
                
                // Form Login
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
                Obx(() => TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible.value,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible.value ? Icons.visibility : Icons.visibility_off,
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
                
                // Tombol Login yang reaktif
                Obx(() => authController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // 3. Panggil fungsi dari controller secara langsung
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
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      )),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/register');
                  },
                  child: const Text(
                    'Belum punya akun? Daftar sekarang',
                    style: TextStyle(color: Colors.white70),
                  ),
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
  final LocalAuthentication auth = LocalAuthentication();
  final UserSession userSession = Get.find();
  final UserController userController = Get.find();

  bool _isCheckingBiometricStatus = true;
  bool _showBiometricLogin = false;
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _loadLastUserAndCheckBiometrics();
  }

  Future<void> _loadLastUserAndCheckBiometrics() async {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final lastUserId = userSession.userId.isNotEmpty ? userSession.userId.value : args?['userId'] as String?;
    
    if (lastUserId == null || lastUserId.isEmpty) {
        setState(() => _isCheckingBiometricStatus = false);
        return;
    }

    final user = await userController.getUserData(lastUserId);
    final canCheckBiometrics = await auth.canCheckBiometrics;
    
    if (mounted) {
      setState(() {
        _lastUserId = lastUserId;
        _showBiometricLogin = canCheckBiometrics && (user?.fingerprintEnabled ?? false);
        _isCheckingBiometricStatus = false;
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Login dengan sidik jari',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated && _lastUserId != null) {
        await userSession.startSession(_lastUserId!);
        await userController.getUserData(_lastUserId!);
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak dapat melakukan autentikasi sidik jari.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingBiometricStatus) {
      return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
    }
    
    if (!_showBiometricLogin) {
      // Tidak menampilkan apa-apa jika biometrik tidak aktif/tersedia
      return const SizedBox.shrink();
    }
    
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _authenticateWithBiometrics,
          icon: const Icon(Icons.fingerprint),
          label: const Text("Login dengan Sidik Jari"),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue.withOpacity(0.8),
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