import 'package:get/get.dart';
import '../../data/services/auth_service.dart';
import '../../app/routes/app_routes.dart';
import '../../widgets/custom_toast.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  String get ownerEmail => _authService.currentUserEmail ?? 'admin@example.com';

  Future<void> logout() async {
    await _authService.logout();
    CustomToast.info('Logged out successfully');
    Get.offAllNamed(Routes.login);
  }
}
