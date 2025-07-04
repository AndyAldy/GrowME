// lib/controllers/auth_controller.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '/controllers/user_controller.dart';
import '/utils/user_session.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final UserController _userController;
  late final UserSession _userSession;

  final RxBool isLoading = false.obs;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();

    if (Get.isRegistered<UserController>()) {
      _userController = Get.find<UserController>();
    } else {
      throw Exception('UserController belum tersedia saat AuthController dibuat');
    }

    if (Get.isRegistered<UserSession>()) {
      _userSession = Get.find<UserSession>();
    } else {
      throw Exception('UserSession belum tersedia saat AuthController dibuat');
    }
  }

  Future<User?> register(String name, String email, String password) async {
    isLoading.value = true;
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _userController.createUser(user.uid, name, email, 0);
        await _userSession.startSession(user.uid);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Registrasi', e.message ?? 'Terjadi kesalahan');
      return null;
    } catch (e, stack) {
      Get.snackbar('Error', 'Kesalahan tidak diketahui: $e');
      print('Unexpected error (register): $e\n$stack');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _userSession.startSession(user.uid);
        await _userController.getUserData(user.uid);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Login', e.message ?? 'Email atau password salah');
      return null;
    } catch (e, stack) {
      Get.snackbar('Error', 'Kesalahan tidak diketahui: $e');
      print('Unexpected error (signIn): $e\n$stack');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final lastUserId = _userSession.userId.value;
    final user = await _userController.getUserData(lastUserId);
    final isFingerprintOn = user?.fingerprintEnabled ?? false;

    await _auth.signOut();
    await _userSession.clearSession();

    Get.offAllNamed(
      '/login',
      arguments: {
        'userId': lastUserId,
        'biometricEnabled': isFingerprintOn,
      },
    );
  }
}
