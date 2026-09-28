import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = AppResponsive.isDesktop(context) || AppResponsive.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SplitEasy Admin',
          style: AppTextStyles.h2(isDark: isDark),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () {
            if (controller.isLoading.value) {
              return const LoadingIndicator(message: 'Loading admin dashboard...');
            }

            return RefreshIndicator(
              onRefresh: controller.loadDashboardData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 20.0 : 16.r),
                physics: const AlwaysScrollableScrollPhysics(),
                child: CenteredContentWrapper(
                  maxWidth: 950,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Metric Cards Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 600) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildMetricCard(
                                    context: context,
                                    title: 'Total Trips',
                                    value: '${controller.totalTripsCount.value}',
                                    icon: Icons.flight_takeoff_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMetricCard(
                                    context: context,
                                    title: 'Total Expenses',
                                    value: '${controller.totalExpensesCount.value} items',
                                    icon: Icons.receipt_long_rounded,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMetricCard(
                                    context: context,
                                    title: 'Total Amount',
                                    value: '₹${controller.totalAmountAcrossTrips.value.toStringAsFixed(2)}',
                                    icon: Icons.account_balance_wallet_rounded,
                                    color: AppColors.owed,
                                  ),
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  context: context,
                                  title: 'Total Trips',
                                  value: '${controller.totalTripsCount.value}',
                                  icon: Icons.flight_takeoff_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildMetricCard(
                                  context: context,
                                  title: 'Total Expenses',
                                  value: '₹${controller.totalAmountAcrossTrips.value.toStringAsFixed(2)}',
                                  subtitle: '${controller.totalExpensesCount.value} items',
                                  icon: Icons.account_balance_wallet_rounded,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: isDesktop ? 20.0 : 20.h),

                      // Quick Action Button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: controller.goToCreateTrip,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Create New Trip'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: isDesktop ? 14.0 : 14.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isDesktop ? 24.0 : 28.h),

                      // Recent Trips Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Recent Trips',
                              style: AppTextStyles.h3(isDark: isDark),
                            ),
                          ),
                          if (controller.recentTripSummaries.isNotEmpty)
                            TextButton(
                              onPressed: controller.goToTripsList,
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
                      SizedBox(height: isDesktop ? 10.0 : 10.h),

                      // Recent Trips List or Empty State
                      if (controller.recentTripSummaries.isEmpty)
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(isDesktop ? 24.0 : 24.r),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.card_travel_rounded,
                                  size: isDesktop ? 48.0 : 48.sp,
                                  color: AppColors.textSecondaryLight,
                                ),
                                SizedBox(height: isDesktop ? 12.0 : 12.h),
                                Text(
                                  'No Trips Created Yet',
                                  style: AppTextStyles.h3(isDark: isDark),
                                ),
                                SizedBox(height: isDesktop ? 6.0 : 6.h),
                                Text(
                                  'Create a trip to start adding participants and splitting expenses!',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodySmall(isDark: isDark),
                                ),
                                SizedBox(height: isDesktop ? 16.0 : 16.h),
                                ElevatedButton.icon(
                                  onPressed: controller.goToCreateTrip,
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Create First Trip'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth >= 600) {
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 420,
                                  mainAxisExtent: 100,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: controller.recentTripSummaries.length,
                                itemBuilder: (context, index) {
                                  return _buildTripCardItem(
                                    context,
                                    controller.recentTripSummaries[index],
                                    isDark,
                                    isDesktop: true,
                                  );
                                },
                              );
                            }

                            return Column(
                              children: controller.recentTripSummaries.map((summary) {
                                return _buildTripCardItem(context, summary, isDark, isDesktop: false);
                              }).toList(),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTripCardItem(
    BuildContext context,
    TripSummaryItem summary,
    bool isDark, {
    required bool isDesktop,
  }) {
    final trip = summary.trip;
    final dateStr = trip.startDate != null
        ? '${DateFormat('MMM d, yyyy').format(trip.startDate!)}${trip.endDate != null ? ' - ${DateFormat('MMM d, yyyy').format(trip.endDate!)}' : ''}'
        : 'No dates set';

    return Card(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 10.h),
      child: InkWell(
        onTap: () => controller.goToTripDetail(trip.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 14.0 : 12.r),
          child: Row(
            children: [
              // Left Icon Badge
              Container(
                padding: EdgeInsets.all(isDesktop ? 10.0 : 10.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  color: AppColors.primary,
                  size: isDesktop ? 22.0 : 22.sp,
                ),
              ),
              SizedBox(width: isDesktop ? 12.0 : 12.w),

              // Middle Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      trip.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge(isDark: isDark)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${trip.destination.isNotEmpty ? '${trip.destination} • ' : ''}${summary.peopleCount} participants',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall(isDark: isDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall(isDark: isDark).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isDesktop ? 8.0 : 8.w),

              // Right Amount & Chevron
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${summary.totalExpenseAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: isDesktop ? 15.0 : 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: isDesktop ? 18.0 : 18.sp,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 16.0 : 16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 8.0 : 8.r),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: isDesktop ? 18.0 : 20.sp),
                ),
                SizedBox(width: isDesktop ? 8.0 : 8.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label(isDark: isDark),
                  ),
                ),
              ],
            ),
            SizedBox(height: isDesktop ? 10.0 : 12.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTextStyles.h2(isDark: isDark).copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall(isDark: isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
