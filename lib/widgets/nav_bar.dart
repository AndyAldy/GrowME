import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;

  const NavBar({super.key, required this.currentIndex});

  void _onTap(int index) {
    // Hindari navigasi ke halaman yang sama
    if (index == currentIndex) return; 

    switch (index) {
      case 0:
        // Gunakan Get.toNamed agar tidak menghapus state
        Get.toNamed('/home');
        break;
      case 1:
        Get.toNamed('/live');
        break;
      case 2:
        Get.toNamed('/ai');
        break;
      case 3:
        Get.toNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _onTap,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Live Chart'),
        BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Tanya Joko'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}