import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX masih digunakan untuk routing & UserSession
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart'; // Menggunakan Provider untuk state
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../utils/user_session.dart';
import '../../theme/halus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();

  // HAPUS inisialisasi controller di sini. Kita akan ambil dari Provider.
  // final AuthController authController = Get.put(AuthController());
  // final UserController userController = Get.put(UserController());

  late final UserSession userSession;

  bool _passwordVisible = false;
  bool _isLoading = false;
  String? _error;
  bool _isCheckingBiometricStatus = true;
  bool _biometricOnlyLogin = false;
  bool _isBiometricAvailable = false;
  String? _lastUserId;
  bool _isInitDone = false; // Flag untuk memastikan inisialisasi hanya sekali

  @override
  void initState() {
    super.initState();
    // Ambil UserSession yang sudah di-register permanen di main.dart
    userSession = Get.find<UserSession>();
  }

  // Gunakan didChangeDependencies untuk mengambil data dari Provider
  // karena method ini dipanggil setelah initState dan memiliki context yang valid.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitDone) {
      _loadLastUserAndCheckBiometrics();
      _isInitDone = true;
    }
  }

  Future<void> _loadLastUserAndCheckBiometrics() async {
    // Ambil UserController dari Provider
    final userController = Provider.of<UserController>(context, listen: false);

    final args = Get.arguments as Map<String, dynamic>?;
    String? userIdFromArgs = args?['userId'];

    if (userIdFromArgs != null) {
      _lastUserId = userIdFromArgs;
      await _checkBiometricStatus(_lastUserId!, userController);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final lastUserIdFromPrefs = prefs.getString('last_user_id');

      if (lastUserIdFromPrefs != null) {
        _lastUserId = lastUserIdFromPrefs;
        await _checkBiometricStatus(_lastUserId!, userController);
      } else {
        if (mounted) {
          setState(() {
            _isCheckingBiometricStatus = false;
          });
        }
      }
    }
  }

  Future<void> _saveLastUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_user_id', userId);
  }

  // Method ini sekarang menerima UserController sebagai argumen
  Future<void> _checkBiometricStatus(String userId, UserController userController) async {
    try {
      // Panggil fetchUserData dari instance controller yang benar
      await userController.fetchUserData(userId);
      final isEnabled = userController.userModel?.fingerprintEnabled ?? false;

      if (mounted) {
        setState(() {
          _isBiometricAvailable = isEnabled;
          _biometricOnlyLogin = isEnabled;
          _isCheckingBiometricStatus = false;
        });

        if (isEnabled) {
          await _loginWithBiometrics();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingBiometricStatus = false;
          _biometricOnlyLogin = false;
          _isBiometricAvailable = false;
          _error = "Gagal memeriksa status biometrik.";
        });
      }
    }
  }

  Future<void> _login() async {
    // Ambil instance controller dari Provider di dalam method
    final authController = Provider.of<AuthController>(context, listen: false);
    final userController = Provider.of<UserController>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final userId = authController.userId;
      if (userId != null) {
        await userController.fetchUserData(userId); // Gunakan controller dari Provider
        await _saveLastUserId(userId);
        Get.offAllNamed('/home'); // Navigasi ke home setelah berhasil
      } else {
        setState(() {
          _error = 'Login gagal: ID pengguna tidak ditemukan.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Login gagal: Email atau Password salah.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    // Ambil instance controller dari Provider di dalam method
    final userController = Provider.of<UserController>(context, listen: false);
    bool isAuthenticated = false;
    
    if (!mounted) return;

    setState(() {
      _error = null;
    });

    try {
      isAuthenticated = await auth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      if(mounted) {
        setState(() {
          _error = 'Otentikasi biometrik gagal: $e';
        });
      }
    }

    if (isAuthenticated) {
      final userId = _lastUserId;
      if (userId != null) {
        await userController.fetchUserData(userId); // Gunakan controller dari Provider
        await _saveLastUserId(userId);
        Get.offAllNamed('/home'); // Navigasi ke home setelah berhasil
      } else {
        if(mounted) {
          setState(() {
            _error = 'ID Pengguna tidak ditemukan. Silakan login manual.';
            _biometricOnlyLogin = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _error = "Otentikasi dibatalkan.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan instance UserController di dalam build method untuk UI
    final userController = context.watch<UserController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isCheckingBiometricStatus
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: _biometricOnlyLogin
                      ? _buildBiometricLoginView(userController)
                      : _buildStandardLoginView(),
                ),
        ),
      ),
    );
  }

  Widget _buildStandardLoginView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Image(
            image: AssetImage('assets/img/Logo GrowME.png'),
            height: 50,
          ),
        ),
        const SizedBox(height: 80),
        const Text(
          'Welcome to GrowME',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 140),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: CustomPaint(painter: SmoothLinePainter()),
        ),
        TextField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(color: Colors.white),
            prefixIcon: const Icon(Icons.lock, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
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
        ),
        const SizedBox(height: 16),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          child: _isLoading
              ? const CircularProgressIndicator(color: Color.fromARGB(255, 68, 255, 137))
              : const Text('Login'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Get.toNamed('/register'),
          child: const Text('Daftar Akun'),
        ),
        if (_isBiometricAvailable) ...[
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('ATAU'),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loginWithBiometrics,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Login dengan Sidik Jari'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildBiometricLoginView(UserController userController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Gunakan sidik jari Anda untuk masuk, ${userController.userModel?.name ?? 'Pengguna'}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 60),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ElevatedButton.icon(
          onPressed: _loginWithBiometrics,
          icon: const Icon(Icons.fingerprint),
          label: const Text('Login dengan Sidik Jari'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _biometricOnlyLogin = false;
              _error = null;
            });
          },
          child: const Text('Gunakan Email & Password'),
        ),
      ],
    );
  }
}
