import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import '../home/home_controller.dart';
import 'trips_controller.dart';

class TripsScreen extends GetView<TripsController> {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Trips'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: controller.goToCreateTrip,
            tooltip: 'Create New Trip',
          ),
          SizedBox(width: isDesktop ? 8.0 : 8.w),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () {
            if (controller.isLoading.value) {
              return const LoadingIndicator(message: 'Loading trips...');
            }

            if (controller.tripSummaries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.card_travel_rounded,
                      size: isDesktop ? 56.0 : 64.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                    SizedBox(height: isDesktop ? 16.0 : 16.h),
                    Text(
                      'No Trips Created Yet',
                      style: AppTextStyles.h3(isDark: isDark),
                    ),
                    SizedBox(height: isDesktop ? 8.0 : 8.h),
                    Text(
                      'Create a trip to manage participants and split expenses',
                      style: AppTextStyles.bodySmall(isDark: isDark),
                    ),
                    SizedBox(height: isDesktop ? 20.0 : 20.h),
                    ElevatedButton.icon(
                      onPressed: controller.goToCreateTrip,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create Trip'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchTrips,
              color: AppColors.primary,
              child: CenteredContentWrapper(
                maxWidth: 950,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 600) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 440,
                          mainAxisExtent: 100,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: controller.tripSummaries.length,
                        itemBuilder: (context, index) {
                          return _buildTripTile(
                            context,
                            controller.tripSummaries[index],
                            isDark,
                            isDesktop: true,
                          );
                        },
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: controller.tripSummaries.length,
                      itemBuilder: (context, index) {
                        return _buildTripTile(
                          context,
                          controller.tripSummaries[index],
                          isDark,
                          isDesktop: false,
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'trips_fab',
        onPressed: controller.goToCreateTrip,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Trip', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTripTile(
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
              // Left Icon
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

              // Middle Info
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

              // Right Amount
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
}
