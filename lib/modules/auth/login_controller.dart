import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/auth_service.dart';
import '../../widgets/custom_toast.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      CustomToast.success('Welcome back to SplitEasy!');
      Get.offAllNamed(Routes.main);
    } catch (e) {
      String msg = 'Login failed';
      if (e is AuthException) {
        msg = e.message;
      } else {
        msg = e.toString().replaceAll('Exception:', '').trim();
      }
      CustomToast.error(msg);
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.register);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
