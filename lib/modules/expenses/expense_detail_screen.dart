import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import 'expense_detail_controller.dart';

class ExpenseDetailScreen extends GetView<ExpenseDetailController> {
  const ExpenseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: controller.goToEditExpense,
            tooltip: 'Edit Expense',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            onPressed: () => _confirmDeleteExpense(context),
            tooltip: 'Delete Expense',
          ),
          SizedBox(width: isDesktop ? 8.0 : 8.w),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () {
            if (controller.isLoading.value && controller.expense.value == null) {
              return const LoadingIndicator(message: 'Loading expense details...');
            }

            final exp = controller.expense.value;
            if (exp == null) {
              return const Center(child: Text('Expense not found'));
            }

            final dateStr = DateFormat('dd/MM/yyyy • h:mm a').format(exp.expenseDate);
            final paidByName = controller.getPersonName(exp.paidByPersonId);

            return SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 20.0 : 16.r),
              child: CenteredContentWrapper(
                maxWidth: 600,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Amount Card
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 20.0 : 16.r),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: isDesktop ? 28.0 : 28.r,
                              backgroundColor: AppColors.primaryLight,
                              child: Icon(
                                _getCategoryIcon(exp.category),
                                color: AppColors.primary,
                                size: isDesktop ? 28.0 : 28.sp,
                              ),
                            ),
                            SizedBox(height: isDesktop ? 12.0 : 12.h),
                            Text(
                              exp.description,
                              style: AppTextStyles.h2(isDark: isDark),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isDesktop ? 6.0 : 6.h),
                            Text(
                              '₹${exp.totalAmount.toStringAsFixed(2)}',
                              style: AppTextStyles.amountLarge(color: AppColors.primary),
                            ),
                            SizedBox(height: isDesktop ? 12.0 : 12.h),
                            const Divider(),
                            SizedBox(height: isDesktop ? 8.0 : 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Paid By:', style: AppTextStyles.label(isDark: isDark)),
                                Text(
                                  paidByName,
                                  style: AppTextStyles.bodyMedium(isDark: isDark)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: isDesktop ? 6.0 : 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Category:', style: AppTextStyles.label(isDark: isDark)),
                                Text(exp.category, style: AppTextStyles.bodyMedium(isDark: isDark)),
                              ],
                            ),
                            SizedBox(height: isDesktop ? 6.0 : 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Split Mode:', style: AppTextStyles.label(isDark: isDark)),
                                Chip(
                                  label: Text(
                                    exp.splitType.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: isDesktop ? 11.0 : 11.sp,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  backgroundColor: AppColors.primaryLight,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            SizedBox(height: isDesktop ? 6.0 : 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Date:', style: AppTextStyles.label(isDark: isDark)),
                                Text(dateStr, style: AppTextStyles.bodySmall(isDark: isDark)),
                              ],
                            ),
                            if (exp.note.isNotEmpty) ...[
                              SizedBox(height: isDesktop ? 6.0 : 6.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Note:', style: AppTextStyles.label(isDark: isDark)),
                                  Text(exp.note, style: AppTextStyles.bodySmall(isDark: isDark)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 24.0 : 24.h),

                    // Participant Shares Section
                    Text('Participant Shares', style: AppTextStyles.h3(isDark: isDark)),
                    SizedBox(height: isDesktop ? 12.0 : 12.h),

                    Column(
                      children: exp.splits.map((s) {
                        final personName = controller.getPersonName(s.personId);
                        final isPayer = s.personId == exp.paidByPersonId;

                        return Card(
                          margin: EdgeInsets.only(bottom: isDesktop ? 8.0 : 8.h),
                          child: Padding(
                            padding: EdgeInsets.all(isDesktop ? 12.0 : 12.r),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primaryLight,
                                  child: Text(
                                    personName.isNotEmpty ? personName[0] : 'P',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: isDesktop ? 12.0 : 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        personName,
                                        style: AppTextStyles.bodyMedium(isDark: isDark)
                                            .copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      if (isPayer) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Paid ₹${exp.totalAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppColors.owed,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${s.shareAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: isDesktop ? 15.0 : 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    if (s.sharePercentage != null)
                                      Text(
                                        '${s.sharePercentage!.toStringAsFixed(1)}%',
                                        style: const TextStyle(fontSize: 11, color: AppColors.primary),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteExpense(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text(
            'Are you sure you want to delete this expense? All shares for this expense will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                Get.back();
                controller.deleteExpense();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
