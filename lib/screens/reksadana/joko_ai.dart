import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/chat_message.dart';
import '../../services/gemini_service.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/message_input_bar.dart';
import '../../widgets/nav_bar.dart';
import '../../theme/theme_provider.dart';
import 'package:get/get.dart'; // Import AppTheme untuk akses tema

// Unused imports removed for cleaner code

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = []; // Nama variabel yang benar
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();
  final FocusNode _inputFocusNode = FocusNode();
  final ThemeProvider themeProvider = Get.find<ThemeProvider>();
  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      text: 'Halo! Saya Joko, asisten AI Anda. Tanyakan apa saja seputar investasi atau reksa dana.',
      isFromUser: false, // Properti yang benar adalah isFromUser
    ));
    _inputFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _inputFocusNode.removeListener(_onFocusChange);
    _inputFocusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_inputFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), _scrollDown);
    }
  }

  // Karena list di-reverse, kita scroll ke min (paling atas, yang sebenarnya adalah paling bawah di tampilan)
  void _scrollDown() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final userMessageText = _textController.text;
    _textController.clear();

    // Memfokuskan kembali ke input setelah mengirim
    _inputFocusNode.requestFocus();

    setState(() {
      _isLoading = true;
      _messages.insert(0, ChatMessage(
        id: _uuid.v4(),
        text: userMessageText,
        isFromUser: true, // Properti yang benar
      ));
    });
    _scrollDown();

    // Menampilkan indikator loading (opsional tapi bagus)
    setState(() {
       _messages.insert(0, ChatMessage(
        id: _uuid.v4(),
        text: '...',
        isFromUser: false,
        isTyping: true,
      ));
    });
    _scrollDown();

    try {
      final responseText = await _geminiService.sendMessage(userMessageText);
      setState(() {
        _messages.removeWhere((msg) => msg.isTyping);
        _messages.insert(0, ChatMessage(
          id: _uuid.v4(),
          text: responseText,
          isFromUser: false,
        ));
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((msg) => msg.isTyping);
        _messages.insert(0, ChatMessage(
          id: _uuid.v4(),
          text: 'Maaf, terjadi kesalahan. Coba lagi nanti.',
          isFromUser: false,
          isError: true,
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joko'),
        backgroundColor: isDark ? Colors.lightBlueAccent : const Color.fromARGB(255, 192, 254, 121),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true, // List dimulai dari bawah
              itemCount: _messages.length, // Menggunakan _messages
              itemBuilder: (context, index) {
                final message = _messages[index]; // Menggunakan _messages
                return MessageBubble(
                  message: message.text,
                  isMe: message.isFromUser, // Menggunakan isFromUser
                  isTyping: message.isTyping,
                );
              },
            ),
          ),
          MessageInputBar(
            // Sambungkan controller & focus node ke input bar
            controller: _textController,
            focusNode: _inputFocusNode,
            onSend: _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 2),
    );
  }
}