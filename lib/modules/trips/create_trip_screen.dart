import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/responsive_layout.dart';
import 'create_trip_controller.dart';

class CreateTripScreen extends GetView<CreateTripController> {
  const CreateTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = controller.existingTrip != null;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final iconSize = isDesktop ? 20.0 : 20.sp;
    final calendarIconSize = isDesktop ? 18.0 : 18.sp;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Trip' : 'Create New Trip'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24.0 : 20.r),
          child: CenteredContentWrapper(
            maxWidth: 550,
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Trip Name
                  CustomTextField(
                    label: 'Trip Name *',
                    hintText: 'e.g. Goa Trip',
                    controller: controller.nameController,
                    prefixIcon: Icon(Icons.flight_takeoff_rounded, size: iconSize),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a trip name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: isDesktop ? 16.0 : 16.h),

                  // Destination
                  CustomTextField(
                    label: 'Destination',
                    hintText: 'e.g. Goa, India',
                    controller: controller.destinationController,
                    prefixIcon: Icon(Icons.location_on_outlined, size: iconSize),
                  ),
                  SizedBox(height: isDesktop ? 16.0 : 16.h),

                  // Date Pickers Row
                  Row(
                    children: [
                      // Start Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Date', style: AppTextStyles.label(isDark: isDark)),
                            SizedBox(height: isDesktop ? 6.0 : 6.h),
                            Obx(
                              () => InkWell(
                                onTap: () => _selectDate(context, isStart: true),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 12.0 : 12.w,
                                    vertical: isDesktop ? 14.0 : 14.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: calendarIconSize, color: AppColors.primary),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          controller.startDate.value != null
                                              ? DateFormat('dd/MM/yyyy').format(controller.startDate.value!)
                                              : 'dd/mm/yyyy',
                                          style: AppTextStyles.bodyMedium(isDark: isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: isDesktop ? 12.0 : 12.w),

                      // End Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('End Date', style: AppTextStyles.label(isDark: isDark)),
                            SizedBox(height: isDesktop ? 6.0 : 6.h),
                            Obx(
                              () => InkWell(
                                onTap: () => _selectDate(context, isStart: false),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop ? 12.0 : 12.w,
                                    vertical: isDesktop ? 14.0 : 14.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: calendarIconSize, color: AppColors.primary),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          controller.endDate.value != null
                                              ? DateFormat('dd/MM/yyyy').format(controller.endDate.value!)
                                              : 'dd/mm/yyyy',
                                          style: AppTextStyles.bodyMedium(isDark: isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 16.0 : 16.h),

                  // Description
                  CustomTextField(
                    label: 'Description',
                    hintText: 'e.g. Vacation with friends',
                    controller: controller.descriptionController,
                    maxLines: 3,
                  ),
                  SizedBox(height: isDesktop ? 28.0 : 32.h),

                  // Save Button
                  Obx(
                    () => CustomButton(
                      text: isEditing ? 'Update Trip' : 'Save Trip',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.saveTrip,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final initial = isStart
        ? (controller.startDate.value ?? DateTime.now())
        : (controller.endDate.value ?? controller.startDate.value ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      if (isStart) {
        controller.startDate.value = picked;
      } else {
        controller.endDate.value = picked;
      }
    }
  }
}
