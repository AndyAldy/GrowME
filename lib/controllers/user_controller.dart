// lib/controllers/user_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
import 'package:GrowME/controllers/auth_controller.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Rxn<UserModel> user = Rxn<UserModel>();
  StreamSubscription<DocumentSnapshot>? _userStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    // Mendengarkan perubahan dari firebaseUser di AuthController
    final authController = Get.find<AuthController>();
    ever(authController.firebaseUser, _onAuthStateChanged);
  }

  void _onAuthStateChanged(auth.User? firebaseUser) {
    if (firebaseUser == null) {
      clearUserData(); // Panggil method pembersihan
    } else {
      _listenToUserData(firebaseUser.uid);
    }
  }

  void _listenToUserData(String uid) {
    _userStreamSubscription?.cancel();
    _userStreamSubscription = _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        user.value = UserModel.fromDocument(snapshot);
      } else {
        user.value = null;
      }
    }, onError: (error) {
      Get.snackbar('Error', 'Gagal memuat data pengguna: $error');
      user.value = null;
    });
  }
  
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
      rethrow; // Lemparkan lagi error agar bisa ditangani di tempat lain jika perlu
    }
  }

  /// Mengupdate status sidik jari di Firestore.
  Future<void> updateFingerprintStatus(String userId, bool isEnabled) async {
    if (userId.isEmpty) return; // Validasi sederhana
    try {
      await _db.collection('users').doc(userId).update({
        'fingerprintEnabled': isEnabled,
      });
      Get.snackbar('Sukses', 'Pengaturan sidik jari telah diperbarui.');
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui status sidik jari: $e');
    }
  }

void reinitializeUser() {
  final authUser = Get.find<AuthController>().firebaseUser.value;
  if (authUser != null) {
    _listenToUserData(authUser.uid);
  }
}

  /// BARU: Method untuk membersihkan data pengguna secara eksplisit.
  Future<void> clearUserData() async {
    await _userStreamSubscription?.cancel();
    _userStreamSubscription = null;
    user.value = null;
  }

  @override
  void onClose() {
    _userStreamSubscription?.cancel();
    super.onClose();
  }

  Future<UserModel?> getUserData(String uid) async {
  // Validasi: Jika UID kosong, tidak perlu ke Firestore.
  if (uid.isEmpty) {
    print('Error: getUserData dipanggil dengan UID kosong.');
    return null;
  }

  try {
    // Lakukan panggilan ke Firestore untuk mengambil dokumen.
    final doc = await _db.collection('users').doc(uid).get();

    // Periksa apakah dokumennya ada dan berisi data.
    if (doc.exists && doc.data() != null) {
      // Jika ada, ubah menjadi objek UserModel dan kembalikan.
      return UserModel.fromDocument(doc);
    } else {
      // Jika dokumen tidak ditemukan, kembalikan null.
      return null;
    }
  } catch (e) {
    // Tangani jika terjadi error (misal: masalah jaringan atau izin).
    Get.snackbar(
      'Error',
      'Gagal mengambil data pengguna: ${e.toString()}',
    );
    return null;
  }
}
}