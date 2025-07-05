import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart'; // Sesuaikan path jika perlu
import '../services/gemini_service.dart'; // Sesuaikan path jika perlu

class JokoAiController extends GetxController {
  // === STATE ===
  // Gunakan RxList agar UI otomatis update saat ada pesan baru.
  var messages = <ChatMessage>[].obs;
  var isLoading = false.obs;

  // === DEPENDENSI ===
  final GeminiService _geminiService = GeminiService();
  final Uuid _uuid = const Uuid();

  @override
  void onInit() {
    super.onInit();
    // Tambahkan pesan selamat datang saat controller pertama kali dibuat.
    messages.add(ChatMessage(
      id: _uuid.v4(),
      text: 'Halo! Saya Joko, asisten Investasi Anda. Tanyakan apa saja seputar investasi atau reksa dana.',
      isFromUser: false,
    ));
  }

  // === LOGIKA INTI ===
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || isLoading.value) return;

    // 1. Tampilkan pesan pengguna dan mulai loading
    isLoading.value = true;
    messages.insert(0, ChatMessage(id: _uuid.v4(), text: text, isFromUser: true));
    
    // 2. Tampilkan indikator "mengetik" dari AI
    messages.insert(0, ChatMessage(id: _uuid.v4(), text: '...', isFromUser: false, isTyping: true));

    try {
      // 3. Kirim pesan ke Gemini Service
      final responseText = await _geminiService.sendMessage(text);
      
      // Hapus indikator "mengetik"
      messages.removeWhere((msg) => msg.isTyping);
      
      // Tambahkan respons dari AI
      messages.insert(0, ChatMessage(id: _uuid.v4(), text: responseText, isFromUser: false));

    } catch (e) {
      // Hapus indikator "mengetik"
      messages.removeWhere((msg) => msg.isTyping);

      // Tampilkan pesan error
      messages.insert(0, ChatMessage(
        id: _uuid.v4(),
        text: 'Maaf, terjadi kesalahan. Coba lagi nanti.',
        isFromUser: false,
        isError: true,
      ));
    } finally {
      // 4. Selesai loading
      isLoading.value = false;
    }
  }
  
  /// Method untuk membersihkan chat saat logout.
  void clearChat() {
    messages.clear();
    // Anda bisa tambahkan pesan selamat datang lagi jika diinginkan
    onInit();
  }
}