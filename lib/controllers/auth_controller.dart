// lib/controllers/auth_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:growmee/controllers/user_controller.dart';
import 'package:growmee/utils/user_session.dart';

// 1. Ganti menjadi GetxController
class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 2. Gunakan Get.find() untuk mengambil controller lain
  final UserController _userController = Get.find();
  final UserSession _userSession = Get.find();

  // 3. Gunakan .obs untuk state yang reaktif
  final RxBool isLoading = false.obs;

  /// Fungsi untuk mendaftarkan pengguna baru.
  /// Ini sudah termasuk membuat user di Auth dan menyimpan datanya di Firestore.
  Future<User?> register(String name, String email, String password) async {
    isLoading.value = true;
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;
      if (user != null) {
        // Panggil UserController untuk membuat data di Firestore
        await _userController.createUser(user.uid, name, email, 0);
        // Mulai sesi
        await _userSession.startSession(user.uid);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Registrasi', e.message ?? 'Terjadi kesalahan');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fungsi untuk login pengguna.
  /// Ini sudah termasuk login di Auth dan mengambil data dari Firestore.
  Future<User?> signInWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;
      if (user != null) {
        // Mulai sesi
        await _userSession.startSession(user.uid);
        // Ambil data user lengkap setelah login
        await _userController.getUserData(user.uid);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Login', e.message ?? 'Email atau password salah');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fungsi untuk logout.
  Future<void> logout() async {
    final lastUserId = _userSession.userId.value;
    final user = await _userController.getUserData(lastUserId);
    final isFingerprintOn = user?.fingerprintEnabled ?? false;

    await _auth.signOut();
    await _userSession.clearSession();
    
    // Arahkan ke halaman login dan kirim argumen untuk biometrik
    Get.offAllNamed(
      '/login', 
      arguments: {
        'userId': lastUserId,
        'biometricEnabled': isFingerprintOn,
      },
    );
  }
}