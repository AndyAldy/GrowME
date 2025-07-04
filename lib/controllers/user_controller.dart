import 'dart:async'; // Diperlukan untuk StreamSubscription

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth; // Alias untuk User dari firebase_auth
import 'package:get/get.dart';
import 'package:GrowME/controllers/auth_controller.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Dapatkan instance AuthController untuk mengetahui status login pengguna
  final AuthController _authController = Get.find();

  // Variabel 'user' sekarang menjadi Rx<UserModel?> untuk konsistensi.
  // UI akan "mendengarkan" perubahan pada variabel ini.
  final Rx<UserModel?> user = Rx<UserModel?>(null);

  // StreamSubscription untuk membatalkan listener saat tidak diperlukan
  StreamSubscription<DocumentSnapshot>? _userStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    // Secara otomatis memantau perubahan status autentikasi (login/logout)
    ever(_authController.user, _onAuthStateChanged);
  }

  /// Method ini akan dipanggil setiap kali status autentikasi berubah.
  void _onAuthStateChanged(auth.User? firebaseUser) {
    if (firebaseUser == null) {
      // Jika user logout, hapus data user dan hentikan listener
      user.value = null;
      _userStreamSubscription?.cancel();
    } else {
      // Jika user login, mulai mendengarkan data user dari Firestore
      _listenToUserData(firebaseUser.uid);
    }
  }

  /// Mendengarkan perubahan pada dokumen user di Firestore secara real-time.
  void _listenToUserData(String uid) {
    _userStreamSubscription?.cancel(); // Hentikan listener sebelumnya jika ada
    _userStreamSubscription =
        _db.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        // Jika dokumen ada, perbarui state 'user' dengan data baru
        user.value = UserModel.fromMap(snapshot.data()!, snapshot.id);
      } else {
        // Jika dokumen tidak ada (misal, user baru yg datanya belum dibuat)
        user.value = null;
      }
    }, onError: (error) {
      Get.snackbar('Error', 'Gagal mendengarkan data pengguna: $error');
      user.value = null;
    });
  }

  /// Membuat dokumen user baru di Firestore.
  /// State lokal akan terupdate otomatis karena adanya stream listener.
  Future<void> createUser(String uid, String name, String email, num saldo) async {
    try {
      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        saldo: saldo,
        fingerprintEnabled: false,
      );
      await _db.collection('users').doc(uid).set(userModel.toMap());
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan data pengguna: $e');
      rethrow;
    }
  }

  /// Mengupdate status sidik jari di Firestore.
  /// State lokal akan terupdate otomatis karena adanya stream listener.
  Future<void> updateFingerprintStatus(String userId, bool isEnabled) async {
    if (userId.isEmpty) return;
    try {
      await _db.collection('users').doc(userId).update({
        'fingerprintEnabled': isEnabled,
      });
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui status sidik jari: $e');
    }
  }

  // Hentikan listener saat controller dihancurkan untuk mencegah memory leak
  @override
  void onClose() {
    _userStreamSubscription?.cancel();
    super.onClose();
  }
}
