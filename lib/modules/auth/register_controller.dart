import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/auth_service.dart';
import '../../widgets/custom_toast.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxString selectedGender = 'Male'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      CustomToast.error('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        gender: selectedGender.value,
        password: passwordController.text.trim(),
      );

      if (response.session == null) {
        CustomToast.info(
          'Registration successful! Please check your email to confirm your account before logging in.',
          title: 'Confirm Email',
        );
      } else {
        CustomToast.success('Registration successful! Please login.');
      }
      Get.back();
    } catch (e) {
      String msg = 'Registration failed';
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

  void goToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
