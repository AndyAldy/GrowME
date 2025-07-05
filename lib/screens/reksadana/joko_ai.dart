import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/joko_ai_controller.dart'; // Import controller baru
import '../../widgets/message_bubble.dart';
import '../../widgets/message_input_bar.dart';
import '../../widgets/nav_bar.dart';
import '../../theme/theme_provider.dart';

// DIUBAH: dari StatefulWidget menjadi StatelessWidget
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan Get.put() agar controller dibuat dan dikelola oleh GetX.
    // GetX akan secara otomatis menggunakan binding jika tersedia.
    final controller = Get.put(JokoAiController());
    final themeProvider = Get.find<ThemeProvider>();
    final textController = TextEditingController();
    final inputFocusNode = FocusNode();

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
            // DIUBAH: Gunakan Obx untuk membuat UI reaktif terhadap perubahan state.
            child: Obx(() => ListView.builder(
              reverse: true, // List dimulai dari bawah
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return MessageBubble(
                  message: message.text,
                  isMe: message.isFromUser,
                  isTyping: message.isTyping,
                );
              },
            )),
          ),
          Obx(() => MessageInputBar(
            controller: textController,
            focusNode: inputFocusNode,
            isLoading: controller.isLoading.value,
            onSend: () {
              if (textController.text.isNotEmpty) {
                controller.sendMessage(textController.text);
                textController.clear();
                inputFocusNode.requestFocus();
              }
            },
          )),
        ],
      ),
      bottomNavigationBar: const NavBar(currentIndex: 2),
    );
  }
}