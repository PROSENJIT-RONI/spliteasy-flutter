import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, 👋',
              style: AppTextStyles.bodySmall(isDark: isDark),
            ),
            Obx(
              () => Text(
                controller.userName,
                style: AppTextStyles.h3(isDark: isDark),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const LoadingIndicator(message: 'Loading dashboard...');
          }

          return RefreshIndicator(
            onRefresh: controller.loadDashboardData,
            color: AppColors.primary,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              physics: const AlwaysScrollableScrollPhysics(),
              child: CenteredContentWrapper(
                maxWidth: 800,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    Obx(
                      () => BalanceCard(
                        totalBalance: controller.totalBalance.value,
                        youOwe: controller.youOwe.value,
                        youAreOwed: controller.youAreOwed.value,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Action Shortcuts
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.add_rounded,
                            label: 'Add Expense',
                            color: AppColors.primary,
                            onTap: controller.goToAddExpense,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.handshake_outlined,
                            label: 'Settle Up',
                            color: AppColors.secondary,
                            onTap: controller.goToSettleUp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.group_add_outlined,
                            label: 'New Group',
                            color: AppColors.accent,
                            onTap: controller.goToCreateGroup,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h),

                    // Recent Groups
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            'Recent Groups',
                            style: AppTextStyles.h3(isDark: isDark),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Switch tab to Groups
                          },
                          child: Text(
                            'View All',
                            style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Obx(
                      () => Column(
                        children: controller.recentGroups.map((group) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            child: Card(
                              child: ListTile(
                                leading: Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    group.icon,
                                    style: TextStyle(fontSize: 22.sp),
                                  ),
                                ),
                                title: Text(
                                  group.name,
                                  style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${group.memberIds.length} members • ${group.category}',
                                  style: AppTextStyles.bodySmall(isDark: isDark),
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () => controller.goToGroupDetail(group.id),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Recent Activity
                    Text(
                      'Recent Activity',
                      style: AppTextStyles.h3(isDark: isDark),
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => Column(
                        children: controller.recentActivities.map((act) {
                          final dateStr = DateFormat('MMM d, h:mm a').format(act.createdAt);
                          return Card(
                            margin: EdgeInsets.only(bottom: 8.h),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: act.amount != null
                                    ? AppColors.primaryLight
                                    : AppColors.owedLight,
                                child: Icon(
                                  act.amount != null
                                      ? Icons.receipt_long_rounded
                                      : Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 20.sp,
                                ),
                              ),
                              title: Text(
                                act.title,
                                style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                '${act.subtitle}\n$dateStr',
                                style: AppTextStyles.bodySmall(isDark: isDark),
                              ),
                              isThreeLine: true,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(height: 8.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall(isDark: isDark).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
