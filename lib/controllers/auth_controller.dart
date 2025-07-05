import 'dart:async';
import 'package:GrowME/utils/user_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:GrowME/controllers/user_controller.dart';
import 'package:GrowME/controllers/joko_ai_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rxn<User> firebaseUser = Rxn<User>(); // Menggunakan Rxn agar bisa null
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
  }

Future<void> register(String name, String email, String password) async {
  isLoading.value = true;
  try {
    final userController = Get.find<UserController>();
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    final user = userCredential.user;
    if (user != null) {
      await userController.createUser(user.uid, name, email, 0);
      // BARIS INI WAJIB DITAMBAHKAN
      // Untuk menyimpan sesi pengguna baru ke penyimpanan permanen
      await Get.find<UserSession>().startSession(user.uid);
    }
  } on FirebaseAuthException catch (e) {
    Get.snackbar('Error Registrasi', e.message ?? 'Terjadi kesalahan');
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
    
    final user = userCredential.user;
    if (user != null) {
      await Get.find<UserSession>().startSession(user.uid);
    }
    
    return user;
  } on FirebaseAuthException catch (e) {
    Get.snackbar('Error Login', e.message ?? 'Email atau password salah');
    return null;
  } finally {
    isLoading.value = false;
  }
}

  /// Penyesuaian: Logika logout yang sudah diperbaiki untuk mencegah race condition.
Future<void> logout() async {
  final userSession = Get.find<UserSession>();
  final userController = Get.find<UserController>();
  final lastUserId = userController.user.value?.uid;

  await userSession.clearActiveSession(); 
  await userController.clearUserData();

  Get.offAllNamed(
    '/login',
    arguments: {'userId': lastUserId},
  );
  
    if (Get.isRegistered<JokoAiController>()) {
    Get.find<JokoAiController>().clearChat();
  }
}
}