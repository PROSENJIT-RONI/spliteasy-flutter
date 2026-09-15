import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/responsive_layout.dart';
import 'register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: CenteredContentWrapper(
              maxWidth: 480,
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join SplitEasy',
                      style: AppTextStyles.h1(isDark: isDark),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Start splitting expenses with your friends easily',
                      style: AppTextStyles.bodySmall(isDark: isDark),
                    ),
                    SizedBox(height: 28.h),

                    // Full Name
                    CustomTextField(
                      label: 'Full Name',
                      hintText: 'e.g. Alex Johnson',
                      controller: controller.nameController,
                      prefixIcon: Icon(Icons.person_outline, size: 20.sp),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Email Address (auth field)
                    CustomTextField(
                      label: 'Email Address',
                      hintText: 'e.g. alex.johnson@example.com',
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined, size: 20.sp),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!GetUtils.isEmail(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Phone Number (contact field)
                    CustomTextField(
                      label: 'Phone Number (Contact)',
                      hintText: 'e.g. +1 555-0192',
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icon(Icons.phone_outlined, size: 20.sp),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Gender Selection
                    Text(
                      'Gender',
                      style: AppTextStyles.label(isDark: isDark),
                    ),
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
                            items: controller.genderOptions.map((gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(
                                  gender,
                                  style: AppTextStyles.bodyMedium(isDark: isDark),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedGender.value = value;
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Password
                    Obx(
                      () => CustomTextField(
                        label: 'Password',
                        hintText: '••••••••',
                        controller: controller.passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        prefixIcon: Icon(Icons.lock_outline, size: 20.sp),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20.sp,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Confirm Password
                    Obx(
                      () => CustomTextField(
                        label: 'Confirm Password',
                        hintText: '••••••••',
                        controller: controller.confirmPasswordController,
                        obscureText: !controller.isConfirmPasswordVisible.value,
                        prefixIcon: Icon(Icons.lock_outline, size: 20.sp),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20.sp,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // Register Button
                    Obx(
                      () => CustomButton(
                        text: 'Create Account',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.register,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Already have an account link
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                          GestureDetector(
                            onTap: controller.goToLogin,
                            child: Text(
                              'Log In',
                              style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
