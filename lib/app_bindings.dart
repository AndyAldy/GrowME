// lib/app_bindings.dart

import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/chart_data_controller.dart';
import 'theme/theme_provider.dart';
import 'utils/user_session.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Inisialisasi service yang harus selalu aktif
    Get.put(ThemeProvider(), permanent: true);
    Get.put(UserSession(), permanent: true);

    // Gunakan lazyPut untuk controller yang tidak perlu langsung aktif
    // fenix: true akan membuat ulang controller jika "dibuang" dari memori
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => UserController(), fenix: true);
    Get.lazyPut(() => ChartDataController(), fenix: true);
  }
}