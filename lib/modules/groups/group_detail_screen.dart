import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import 'group_detail_controller.dart';

class GroupDetailScreen extends GetView<GroupDetailController> {
  const GroupDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.group.value?.name ?? 'Group Details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () {},
            tooltip: 'Add Member',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const LoadingIndicator(message: 'Loading group details...');
          }

          final g = controller.group.value;
          if (g == null) {
            return const Center(child: Text('Group not found'));
          }

          return Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                child: CenteredContentWrapper(
                  maxWidth: 800,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36.r,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          g.icon,
                          style: TextStyle(fontSize: 36.sp),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        g.name,
                        style: AppTextStyles.h2(isDark: isDark),
                      ),
                      if (g.description.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          g.description,
                          style: AppTextStyles.bodySmall(isDark: isDark),
                        ),
                      ],
                      SizedBox(height: 16.h),

                      // Action Buttons: Add Expense / Settle Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: controller.goToAddExpense,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add Expense'),
                          ),
                          SizedBox(width: 12.w),
                          OutlinedButton.icon(
                            onPressed: controller.goToSettleUp,
                            icon: const Icon(Icons.handshake_outlined),
                            label: const Text('Settle Up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Switcher
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                ),
                child: CenteredContentWrapper(
                  maxWidth: 800,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => controller.activeTab.value = 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: controller.activeTab.value == 0
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Expenses (${controller.groupExpenses.length})',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: controller.activeTab.value == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: controller.activeTab.value == 0
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => controller.activeTab.value = 1,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: controller.activeTab.value == 1
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Members (${controller.members.length})',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: controller.activeTab.value == 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: controller.activeTab.value == 1
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Body
              Expanded(
                child: CenteredContentWrapper(
                  maxWidth: 800,
                  child: IndexedStack(
                    index: controller.activeTab.value,
                    children: [
                      // Expenses Tab
                      controller.groupExpenses.isEmpty
                          ? Center(
                              child: Text(
                                'No expenses in this group yet',
                                style: AppTextStyles.bodyMedium(isDark: isDark),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(16.r),
                              itemCount: controller.groupExpenses.length,
                              itemBuilder: (context, index) {
                                final exp = controller.groupExpenses[index];
                                final dateStr =
                                    DateFormat('MMM d, yyyy').format(exp.createdAt);

                                return Card(
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primaryLight,
                                      child: Icon(
                                        _getCategoryIcon(exp.category),
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    title: Text(
                                      exp.description,
                                      style: AppTextStyles.bodyLarge(isDark: isDark)
                                          .copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Paid by ${exp.paidByUserId == 'user_me' ? 'You' : 'Member'} • $dateStr',
                                      style: AppTextStyles.bodySmall(isDark: isDark),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${exp.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                        Text(
                                          exp.paidByUserId == 'user_me'
                                              ? 'you lent \$${(exp.amount - (exp.splitDetails['user_me'] ?? 0)).toStringAsFixed(2)}'
                                              : 'you owe \$${(exp.splitDetails['user_me'] ?? 0).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: exp.paidByUserId == 'user_me'
                                                ? AppColors.owed
                                                : AppColors.owe,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                      // Members Tab
                      ListView.builder(
                        padding: EdgeInsets.all(16.r),
                        itemCount: controller.members.length,
                        itemBuilder: (context, index) {
                          final member = controller.members[index];
                          final isMe = member.id == 'user_me';

                          return Card(
                            margin: EdgeInsets.only(bottom: 8.h),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  member.name[0],
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                isMe ? '${member.name} (You)' : member.name,
                                style: AppTextStyles.bodyMedium(isDark: isDark)
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                member.phone,
                                style: AppTextStyles.bodySmall(isDark: isDark),
                              ),
                              trailing: Chip(
                                label: Text(
                                  isMe ? 'Creator' : 'Member',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                                backgroundColor: AppColors.primaryLight,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'rent':
        return Icons.home_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }
}
