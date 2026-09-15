import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double youOwe;
  final double youAreOwed;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.youOwe,
    required this.youAreOwed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            Text(
              'Total Balance',
              style: AppTextStyles.label(isDark: isDark),
            ),
            SizedBox(height: 6.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${totalBalance >= 0 ? '+' : ''}\$${totalBalance.abs().toStringAsFixed(2)}',
                style: AppTextStyles.amountLarge(
                  color: totalBalance > 0
                      ? AppColors.owed
                      : totalBalance < 0
                          ? AppColors.owe
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            const Divider(),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              size: 16.sp,
                              color: AppColors.owe,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'You owe',
                              style: AppTextStyles.bodySmall(isDark: isDark),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '\$${youOwe.toStringAsFixed(2)}',
                          style: AppTextStyles.amountMedium(color: AppColors.owe),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 36.h,
                  width: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                Expanded(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 16.sp,
                              color: AppColors.owed,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'You are owed',
                              style: AppTextStyles.bodySmall(isDark: isDark),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '\$${youAreOwed.toStringAsFixed(2)}',
                          style: AppTextStyles.amountMedium(color: AppColors.owed),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
