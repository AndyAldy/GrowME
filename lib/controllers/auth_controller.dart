import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '/controllers/user_controller.dart';
import '/utils/user_session.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Rx<User?> untuk menampung user dari Firebase Auth yang bisa di-observe
  final Rx<User?> user = Rx<User?>(null);

  late final UserController _userController;
  late final UserSession _userSession;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind stream dari authStateChanges ke variabel reaktif 'user'
    user.bindStream(_auth.authStateChanges());

    // Pastikan controller lain sudah siap sebelum digunakan
    // Menggunakan .put() jika belum ada dan .find() jika sudah ada
    _userController = Get.put(UserController());
    _userSession = Get.put(UserSession());
  }

  Future<User?> register(String name, String email, String password) async {
    isLoading.value = true;
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Buat dokumen user di Firestore.
        // UserController akan otomatis mendengarkan data ini.
        await _userController.createUser(firebaseUser.uid, name, email, 0);
        await _userSession.startSession(firebaseUser.uid);
      }
      return firebaseUser;
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

      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        await _userSession.startSession(firebaseUser.uid);
        // TIDAK PERLU LAGI memanggil getUserData secara manual.
        // UserController sudah mendengarkan perubahan auth state dan akan
        // mengambil data user secara otomatis.
      }
      return firebaseUser;
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
    // TIDAK PERLU LAGI mengambil data dari Firestore.
    // Cukup akses data yang sudah ada di UserController.
    final isFingerprintOn = _userController.user.value?.fingerprintEnabled ?? false;

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
