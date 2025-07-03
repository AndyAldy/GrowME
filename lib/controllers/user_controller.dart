// lib/controllers/user_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/user_model.dart'; // Pastikan path ini benar

class UserController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Rx<UserModel?> untuk menampung data user yang bisa di-observe
  final Rx<UserModel?> userModel = Rx<UserModel?>(null);

  // Getter untuk akses yang lebih mudah di UI
  UserModel? get user => userModel.value;

  Future<void> createUser(String uid, String name, String email, num saldo) async {
    try {
      final user = UserModel(
        uid: uid,
        name: name,
        email: email,
        saldo: saldo,
        fingerprintEnabled: false,
      );
      await _db.collection('users').doc(uid).set(user.toMap());
      userModel.value = user;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan data pengguna: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    if (uid.isEmpty) return null;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data()!, doc.id);
        userModel.value = user;
        return user;
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data pengguna: $e');
      return null;
    }
  }
  
  Future<void> updateFingerprintStatus(String userId, bool isEnabled) async {
    try {
      await _db.collection('users').doc(userId).update({
        'fingerprintEnabled': isEnabled,
      });
      if (userModel.value != null) {
        // Perbarui state lokal agar UI langsung berubah
        userModel.value = userModel.value!.copyWith(fingerprintEnabled: isEnabled);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui status sidik jari: $e');
    }
  }
}