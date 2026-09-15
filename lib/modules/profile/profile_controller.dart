import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/storage_service.dart';
import '../../app/routes/app_routes.dart';
import '../../widgets/custom_toast.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxString selectedGender = 'Male'.obs;
  final Rx<String?> localAvatarPath = Rx<String?>(null);
  final RxBool isLoading = false.obs;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    ever(_authService.currentUser, (_) => _loadProfile());
  }

  void _loadProfile() {
    user.value = _authService.currentUser.value;
    if (user.value != null) {
      nameController.text = user.value!.name;
      emailController.text = user.value!.email;
      phoneController.text = user.value!.phone;
      selectedGender.value = user.value!.gender;
      localAvatarPath.value = user.value!.avatarPath;
    }
  }

  Future<void> pickAvatar(ImageSource source) async {
    final path = await _storageService.pickImage(source);
    if (path != null) {
      localAvatarPath.value = path;
    }
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      final updated = await _authService.updateProfile(
        name: nameController.text.trim(),
        gender: selectedGender.value,
        avatarPath: localAvatarPath.value,
      );
      user.value = updated;
      CustomToast.success('Profile updated successfully!');
    } catch (e) {
      CustomToast.error('Failed to update profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    CustomToast.info('Logged out successfully');
    Get.offAllNamed(Routes.login);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
