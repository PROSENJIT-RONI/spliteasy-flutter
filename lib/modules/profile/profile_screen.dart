import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/responsive_layout.dart';
import 'profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: CenteredContentWrapper(
            maxWidth: 550,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar Section
                Center(
                  child: Stack(
                    children: [
                      Obx(
                        () {
                          final path = controller.localAvatarPath.value;
                          final u = controller.user.value;

                          if (path != null && path.isNotEmpty) {
                            return CircleAvatar(
                              radius: 50.r,
                              backgroundImage: FileImage(File(path)),
                            );
                          } else if (u?.avatarUrl != null) {
                            return CircleAvatar(
                              radius: 50.r,
                              backgroundImage: NetworkImage(u!.avatarUrl!),
                            );
                          }

                          return CircleAvatar(
                            radius: 50.r,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              (u?.name.isNotEmpty ?? false) ? u!.name[0] : 'U',
                              style: TextStyle(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18.r,
                          backgroundColor: AppColors.primary,
                          child: IconButton(
                            padding: ZeroInsets.instance,
                            icon: Icon(
                              Icons.camera_alt_rounded,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                            onPressed: () => _showImagePickerModal(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.h),

                // Name
                CustomTextField(
                  label: 'Full Name',
                  controller: controller.nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                SizedBox(height: 16.h),

                // Email
                CustomTextField(
                  label: 'Email Address',
                  controller: controller.emailController,
                  readOnly: true,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                SizedBox(height: 16.h),

                // Phone (Readonly)
                CustomTextField(
                  label: 'Phone Number',
                  controller: controller.phoneController,
                  readOnly: true,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                SizedBox(height: 16.h),

                // Gender
                Text('Gender', style: AppTextStyles.label(isDark: isDark)),
                SizedBox(height: 6.h),
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedGender.value,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        items: controller.genderOptions.map((g) {
                          return DropdownMenuItem<String>(
                            value: g,
                            child: Text(
                              g,
                              style: AppTextStyles.bodyMedium(isDark: isDark),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedGender.value = val;
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 28.h),

                // Save Profile Button
                Obx(
                  () => CustomButton(
                    text: 'Save Changes',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.updateProfile,
                  ),
                ),
                SizedBox(height: 16.h),

                // App Info Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: ZeroInsets.instance,
                          leading: const Icon(Icons.info_outline, color: AppColors.primary),
                          title: const Text('SplitEasy Version'),
                          subtitle: const Text('1.0.0 (UI Prototype Phase)'),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: ZeroInsets.instance,
                          leading: const Icon(Icons.security_outlined, color: AppColors.primary),
                          title: const Text('Privacy & Security'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 28.h),

                // Logout Button
                CustomButton(
                  text: 'Log Out',
                  isOutlined: true,
                  backgroundColor: AppColors.owe,
                  textColor: AppColors.owe,
                  icon: Icons.logout_rounded,
                  onPressed: controller.logout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImagePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Get.back();
                  controller.pickAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Get.back();
                  controller.pickAvatar(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
class ZeroInsets {
  static const EdgeInsets instance = EdgeInsets.zero;
}
