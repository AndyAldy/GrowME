import 'package:get/get.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/portfolio/Chart_screen.dart';
import 'screens/reksadana/joko_ai.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/loading/splash_screen.dart';

final List<GetPage> appPages = [
  // Rute awal
  GetPage(
    name: '/',
    page: () => const SplashScreen(),
    transition: Transition.fadeIn,
  ),
  // Rute lainnya dengan transisi halus
  GetPage(
    name: '/login',
    page: () => const LoginScreen(),
    transition: Transition.leftToRight,
    transitionDuration: const Duration(milliseconds: 400),
  ),
  GetPage(
    name: '/register',
    page: () => const RegisterScreen(),
    transition: Transition.leftToRight,
    transitionDuration: const Duration(milliseconds: 400),
  ),
  GetPage(
    name: '/home',
    page: () => const HomeScreen(),
    transition: Transition.leftToRight,
    transitionDuration: const Duration(milliseconds: 400),
  ),
  GetPage(
    name: '/live',
    page: () => const ChartScreen(),
    transition: Transition.leftToRight,
    transitionDuration: const Duration(milliseconds: 400),
  ),
  GetPage(
    name: '/ai',
    page: () => const ChatScreen(),
    transition: Transition.leftToRight,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: '/profile',
    page: () => const ProfileScreen(),
    transition: Transition.leftToRight,
    transitionDuration: const Duration(milliseconds: 400),
  ),
];
