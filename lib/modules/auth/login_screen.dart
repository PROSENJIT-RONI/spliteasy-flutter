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
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final logoSize = isDesktop ? 72.0 : 80.w;
    final logoIconSize = isDesktop ? 36.0 : 40.sp;
    final fieldIconSize = isDesktop ? 20.0 : 20.sp;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24.0 : 24.r,
              vertical: isDesktop ? 32.0 : 24.r,
            ),
            child: CenteredContentWrapper(
              maxWidth: 440,
              child: Card(
                elevation: isDesktop ? 4 : 0,
                color: isDesktop
                    ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32.0 : 0.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Logo
                        Center(
                          child: Container(
                            width: logoSize,
                            height: logoSize,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(isDesktop ? 14.0 : 16.r),
                            child: Image.asset(
                              'assets/logos/logo.png',
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.flight_takeoff_rounded,
                                size: logoIconSize,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 16.0 : 20.h),
                        Text(
                          'Admin Portal',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h1(isDark: isDark),
                        ),
                        SizedBox(height: isDesktop ? 6.0 : 6.h),
                        Text(
                          'Log in to manage trips, participants & expenses',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall(isDark: isDark),
                        ),
                        SizedBox(height: isDesktop ? 28.0 : 32.h),

                        // Email Input
                        CustomTextField(
                          label: 'Admin Email',
                          hintText: 'admin@example.com',
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(Icons.email_outlined, size: fieldIconSize),
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
                        SizedBox(height: isDesktop ? 16.0 : 16.h),

                        // Password Input
                        Obx(
                          () => CustomTextField(
                            label: 'Password',
                            hintText: '••••••••',
                            controller: controller.passwordController,
                            obscureText: !controller.isPasswordVisible.value,
                            prefixIcon: Icon(Icons.lock_outline, size: fieldIconSize),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: fieldIconSize,
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
                        SizedBox(height: isDesktop ? 24.0 : 28.h),

                        // Login Button
                        Obx(
                          () => CustomButton(
                            text: 'Log In',
                            isLoading: controller.isLoading.value,
                            onPressed: controller.login,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
