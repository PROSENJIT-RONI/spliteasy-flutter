import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/responsive_layout.dart';
import 'login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: CenteredContentWrapper(
              maxWidth: 480,
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo
                    Center(
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.all(16.r),
                        child: Image.asset(
                          'assets/logos/logo.png',
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.call_split_rounded,
                            size: 40.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1(isDark: isDark),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Log in to manage your shared expenses',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall(isDark: isDark),
                    ),
                    SizedBox(height: 32.h),

                    // Email Input
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

                    // Password Input
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
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Login Button
                    Obx(
                      () => CustomButton(
                        text: 'Log In',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.login,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Register Switch Link
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodySmall(isDark: isDark),
                          ),
                          GestureDetector(
                            onTap: controller.goToRegister,
                            child: Text(
                              'Register',
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
