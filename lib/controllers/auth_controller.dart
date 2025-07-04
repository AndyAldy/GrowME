import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:GrowME/controllers/user_controller.dart'; // Pastikan path ini benar & huruf kecil
import 'package:GrowME/utils/user_session.dart';     // Pastikan path ini benar & huruf kecil

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  // Hapus `late final` dan jangan inisialisasi di sini
  // UserController _userController; 
  // UserSession _userSession;

  @override
  void onInit() {
    super.onInit();
    // Bind stream dari authStateChanges ke variabel reaktif 'user'
    user.bindStream(_auth.authStateChanges());

    // FIX: HAPUS SEMUA `Get.put()` ATAU `Get.find()` DARI `onInit`
    // Biarkan AppBindings yang menangani pembuatan controller.
  }

  Future<User?> register(String name, String email, String password) async {
    isLoading.value = true;
    try {
      // Panggil Get.find() HANYA saat dibutuhkan di dalam method
      final userController = Get.find<UserController>();
      final userSession = Get.find<UserSession>();

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await userController.createUser(firebaseUser.uid, name, email, 0);
        await userSession.startSession(firebaseUser.uid);
      }
      return firebaseUser;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Registrasi', e.message ?? 'Terjadi kesalahan');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    isLoading.value = true;
    try {
      // Panggil Get.find() HANYA saat dibutuhkan di dalam method
      final userSession = Get.find<UserSession>();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await userSession.startSession(firebaseUser.uid);
      }
      return firebaseUser;
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error Login', e.message ?? 'Email atau password salah');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    // Panggil Get.find() HANYA saat dibutuhkan di dalam method
    final userSession = Get.find<UserSession>();
    final userController = Get.find<UserController>();

    final lastUserId = userSession.userId.value;
    final isFingerprintOn = userController.user.value?.fingerprintEnabled ?? false;

    await _auth.signOut();
    await userSession.clearSession();

    Get.offAllNamed(
      '/login',
      arguments: {
        'userId': lastUserId,
        'biometricEnabled': isFingerprintOn,
      },
    );
  }
}