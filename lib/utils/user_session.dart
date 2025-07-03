// lib/utils/user_session.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserSession extends GetxController {
  final _storage = GetStorage();
  static const _userIdKey = 'userId';

  // RxString untuk reaktivitas di seluruh aplikasi
  final RxString userId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Muat userId dari penyimpanan saat aplikasi dimulai
    final storedUserId = _storage.read<String>(_userIdKey);
    if (storedUserId != null && storedUserId.isNotEmpty) {
      userId.value = storedUserId;
    }
  }

  /// Memulai sesi baru dengan menyimpan UID pengguna.
  Future<void> startSession(String uid) async {
    userId.value = uid;
    await _storage.write(_userIdKey, uid);
  }

  /// Menghapus sesi pengguna saat logout.
  Future<void> clearSession() async {
    userId.value = '';
    await _storage.remove(_userIdKey);
  }

  /// Mengecek apakah ada pengguna yang sedang login.
  bool get isLoggedIn => userId.value.isNotEmpty;
}