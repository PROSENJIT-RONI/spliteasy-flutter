import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/responsive_layout.dart';
import 'profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final avatarRadius = isDesktop ? 44.0 : 44.r;
    final avatarIconSize = isDesktop ? 48.0 : 48.sp;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 20.r),
          child: CenteredContentWrapper(
            maxWidth: 480,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: isDesktop ? 12.0 : 12.h),

                // Admin Avatar Badge
                Center(
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      size: avatarIconSize,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(height: isDesktop ? 16.0 : 16.h),

                // Admin Email
                Text(
                  'App Owner / Admin',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall(isDark: isDark),
                ),
                SizedBox(height: isDesktop ? 4.0 : 4.h),
                Text(
                  controller.ownerEmail,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2(isDark: isDark),
                ),
                SizedBox(height: isDesktop ? 28.0 : 32.h),

                // App Info Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 20.0 : 16.r),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.info_outline, color: AppColors.primary),
                          title: const Text('SplitEasy Version'),
                          subtitle: const Text('2.0.0 (Single-Admin Trip Expense Manager)'),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.security_outlined, color: AppColors.primary),
                          title: const Text('Role & Permissions'),
                          subtitle: const Text('Full Administrative Access'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isDesktop ? 28.0 : 32.h),

                // Log Out Button
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
}
