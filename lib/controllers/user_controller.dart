import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get/get.dart';
// Path import diperbaiki
import 'package:GrowME/controllers/auth_controller.dart'; 
import '../models/user_model.dart';

class UserController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthController _authController = Get.find();
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  StreamSubscription<DocumentSnapshot>? _userStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    // Mendengarkan variabel 'user' dari AuthController
    ever(_authController.user, _onAuthStateChanged);
  }

  void _onAuthStateChanged(auth.User? firebaseUser) {
    if (firebaseUser == null) {
      user.value = null;
      _userStreamSubscription?.cancel();
    } else {
      _listenToUserData(firebaseUser.uid);
    }
  }

  /// Mendengarkan perubahan data pengguna secara real-time.
  void _listenToUserData(String uid) {
    _userStreamSubscription?.cancel();
    _userStreamSubscription =
        // Casting DocumentSnapshot ke tipe yang benar
        _db.collection('users').doc(uid).snapshots().listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        // FIX: Menggunakan constructor `fromDocument` yang benar sesuai model Anda.
        user.value = UserModel.fromDocument(snapshot);
      } else {
        user.value = null;
      }
    }, onError: (error) {
      Get.snackbar('Error', 'Gagal mendengarkan data pengguna: $error');
      user.value = null;
    });
  }

  /// Mengambil data pengguna satu kali saja.
  Future<UserModel?> getUserData(String uid) async {
    if (uid.isEmpty) return null;
    try {
      // Casting DocumentSnapshot ke tipe yang benar
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        // FIX: Menggunakan constructor `fromDocument` yang benar sesuai model Anda.
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data untuk sesi: $e');
      return null;
    }
  }

  /// Membuat dokumen pengguna baru di Firestore.
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

  @override
  void onClose() {
    _userStreamSubscription?.cancel();
    super.onClose();
  }
}