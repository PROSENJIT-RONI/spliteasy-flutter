import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../data/models/activity_model.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import 'activity_controller.dart';

class ActivityScreen extends GetView<ActivityController> {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const LoadingIndicator(message: 'Loading activity...');
          }

          if (controller.activities.isEmpty) {
            return Center(
              child: Text(
                'No activity recorded yet',
                style: AppTextStyles.bodyMedium(isDark: isDark),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadActivities,
            color: AppColors.primary,
            child: CenteredContentWrapper(
              maxWidth: 800,
              child: ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: controller.activities.length,
                itemBuilder: (context, index) {
                  final act = controller.activities[index];
                  final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(act.createdAt);

                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22.r,
                            backgroundColor: act.type == ActivityType.settlement
                                ? AppColors.owedLight
                                : AppColors.primaryLight,
                            child: Icon(
                              act.type == ActivityType.settlement
                                  ? Icons.handshake_rounded
                                  : Icons.receipt_long_rounded,
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  act.title,
                                  style: AppTextStyles.bodyMedium(isDark: isDark)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  act.subtitle,
                                  style: AppTextStyles.bodySmall(isDark: isDark),
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    if (act.groupName != null) ...[
                                      Chip(
                                        label: Text(
                                          act.groupName!,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        backgroundColor: AppColors.primaryLight,
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                      ),
                                      SizedBox(width: 8.w),
                                    ],
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (act.amount != null)
                            Text(
                              '\$${act.amount!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
