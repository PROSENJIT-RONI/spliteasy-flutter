import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/responsive_layout.dart';
import 'settle_up_controller.dart';

class SettleUpScreen extends GetView<SettleUpController> {
  const SettleUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settle Up Balance'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: CenteredContentWrapper(
            maxWidth: 500,
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.handshake_rounded,
                    size: 64.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Record a Payment',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h2(isDark: isDark),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Settle outstanding balance between group members or friends',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall(isDark: isDark),
                  ),
                  SizedBox(height: 28.h),

                  // Who Paid (Payer)
                  Text('Payer (Who is paying?)', style: AppTextStyles.label(isDark: isDark)),
                  SizedBox(height: 6.h),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedPayer.value?.id,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          items: controller.users.map((u) {
                            return DropdownMenuItem<String>(
                              value: u.id,
                              child: Text(
                                u.id == 'user_me' ? '${u.name} (You)' : u.name,
                                style: AppTextStyles.bodyMedium(isDark: isDark),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            final match = controller.users.firstWhereOrNull((u) => u.id == val);
                            controller.selectedPayer.value = match;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Who Received (Payee)
                  Text('Payee (Who is receiving?)', style: AppTextStyles.label(isDark: isDark)),
                  SizedBox(height: 6.h),
                  Obx(
                    () => Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedPayee.value?.id,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          items: controller.users.map((u) {
                            return DropdownMenuItem<String>(
                              value: u.id,
                              child: Text(
                                u.id == 'user_me' ? '${u.name} (You)' : u.name,
                                style: AppTextStyles.bodyMedium(isDark: isDark),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            final match = controller.users.firstWhereOrNull((u) => u.id == val);
                            controller.selectedPayee.value = match;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Amount
                  CustomTextField(
                    label: 'Amount (\$)',
                    hintText: '0.00',
                    controller: controller.amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Icon(Icons.attach_money_rounded, size: 20.sp),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter settlement amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Note / Payment Method
                  CustomTextField(
                    label: 'Note / Payment Method (Optional)',
                    hintText: 'e.g. Paid via Venmo, Cash, Zelle',
                    controller: controller.noteController,
                    prefixIcon: Icon(Icons.note_alt_outlined, size: 20.sp),
                  ),
                  SizedBox(height: 32.h),

                  // Save Settlement Button
                  Obx(
                    () => CustomButton(
                      text: 'Record Settlement',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.confirmSettlement,
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
}
