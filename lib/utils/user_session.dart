// lib/utils/user_session.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UserSession extends GetxController {
  final _storage = GetStorage();
  // Gunakan nama kunci yang sama dan konsisten
  static const _userIdKey = 'userId';

  // Variabel ini untuk sesi yang sedang aktif di memori
  final RxString activeUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Saat aplikasi dimulai, coba isi sesi aktif dari penyimpanan
    final storedUserId = _storage.read<String>(_userIdKey);
    if (storedUserId != null) {
      activeUserId.value = storedUserId;
    }
  }

  /// Memulai sesi baru dan MENYIMPAN ID ke penyimpanan permanen
  Future<void> startSession(String uid) async {
    activeUserId.value = uid;
    await _storage.write(_userIdKey, uid);
  }

  /// Mengunci aplikasi dengan MENGOSONGKAN sesi aktif di memori,
  /// TAPI TIDAK MENGHAPUS DARI PENYIMPANAN.
  Future<void> clearActiveSession() async {
    activeUserId.value = '';
    // Perhatikan: Tidak ada lagi `_storage.remove()` di sini.
  }
}