import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import 'balances_controller.dart';

class BalancesScreen extends GetView<BalancesController> {
  const BalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balances Breakdown'),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const LoadingIndicator(message: 'Calculating balances...');
          }

          if (controller.friendBalances.isEmpty) {
            return Center(
              child: Text(
                'No active balances with friends',
                style: AppTextStyles.bodyMedium(isDark: isDark),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.calculateBalances,
            color: AppColors.primary,
            child: CenteredContentWrapper(
              maxWidth: 800,
              child: ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: controller.friendBalances.length,
                itemBuilder: (context, index) {
                  final item = controller.friendBalances[index];
                  final net = item.netBalance;

                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12.r),
                      leading: CircleAvatar(
                        radius: 24.r,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          item.user.name[0],
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        item.user.name,
                        style: AppTextStyles.bodyLarge(isDark: isDark)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        net > 0
                            ? 'owes you \$${net.toStringAsFixed(2)}'
                            : net < 0
                                ? 'you owe \$${net.abs().toStringAsFixed(2)}'
                                : 'settled up',
                        style: TextStyle(
                          color: net > 0
                              ? AppColors.owed
                              : net < 0
                                  ? AppColors.owe
                                  : AppColors.settled,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: net != 0
                          ? ElevatedButton(
                              onPressed: () => controller.goToSettleUp(
                                item.user.id,
                                net.abs(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: net < 0 ? AppColors.owe : AppColors.owed,
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              ),
                              child: Text(
                                net < 0 ? 'Settle Up' : 'Remind',
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded, color: AppColors.owed),
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
