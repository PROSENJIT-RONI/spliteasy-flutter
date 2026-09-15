import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../data/models/expense_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/responsive_layout.dart';
import 'add_expense_controller.dart';

class AddExpenseScreen extends GetView<AddExpenseController> {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: CenteredContentWrapper(
            maxWidth: 600,
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Group Picker
                  Text('Select Group / Context', style: AppTextStyles.label(isDark: isDark)),
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
                          value: controller.selectedGroup.value?.id,
                          hint: const Text('Non-group (Direct Split)'),
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          items: controller.groups.map((g) {
                            return DropdownMenuItem<String>(
                              value: g.id,
                              child: Text(
                                '${g.icon} ${g.name}',
                                style: AppTextStyles.bodyMedium(isDark: isDark),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            final match = controller.groups.firstWhereOrNull((g) => g.id == val);
                            controller.onGroupSelected(match);
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Description
                  CustomTextField(
                    label: 'Description',
                    hintText: 'e.g. Dinner, Taxi, Hotel',
                    controller: controller.descriptionController,
                    prefixIcon: Icon(Icons.description_outlined, size: 20.sp),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Amount Input
                  CustomTextField(
                    label: 'Amount (\$)',
                    hintText: '0.00',
                    controller: controller.amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Icon(Icons.attach_money_rounded, size: 20.sp),
                    onChanged: (_) => controller.update(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Category Selector
                  Text('Category', style: AppTextStyles.label(isDark: isDark)),
                  SizedBox(height: 8.h),
                  SizedBox(
                    height: 48.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      separatorBuilder: (context, index) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final cat = controller.categories[index];
                        return Obx(() {
                          final isSelected = controller.selectedCategory.value == cat['name'];
                          return ChoiceChip(
                            avatar: Icon(
                              cat['icon'] as IconData,
                              size: 18.sp,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                            label: Text(cat['name'] as String),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectedCategory.value = cat['name'] as String;
                              }
                            },
                          );
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Paid By Selector
                  Text('Paid By', style: AppTextStyles.label(isDark: isDark)),
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
                          value: controller.selectedPaidByUserId.value,
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          items: controller.availableParticipants.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(
                                p.id == 'user_me' ? 'You (${p.name})' : p.name,
                                style: AppTextStyles.bodyMedium(isDark: isDark),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedPaidByUserId.value = val;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Split Options Section
                  Text('Split Mode', style: AppTextStyles.h3(isDark: isDark)),
                  SizedBox(height: 10.h),
                  Obx(
                    () => SegmentedButton<SplitType>(
                      segments: const [
                        ButtonSegment(
                          value: SplitType.equal,
                          label: Text('Equal'),
                          icon: Icon(Icons.drag_handle_rounded),
                        ),
                        ButtonSegment(
                          value: SplitType.unequal,
                          label: Text('Unequal'),
                          icon: Icon(Icons.tune_rounded),
                        ),
                        ButtonSegment(
                          value: SplitType.percentage,
                          label: Text('Percentage'),
                          icon: Icon(Icons.percent_rounded),
                        ),
                      ],
                      selected: {controller.selectedSplitType.value},
                      onSelectionChanged: (set) {
                        controller.selectedSplitType.value = set.first;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Live Split Preview List
                  Obx(
                    () {
                      final details = controller.calculateSplitDetails();
                      return Column(
                        children: controller.availableParticipants.map((p) {
                          final isIncluded = controller.selectedParticipantIds.contains(p.id);
                          final shareVal = details[p.id] ?? 0.0;

                          return Card(
                            margin: EdgeInsets.only(bottom: 8.h),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isIncluded,
                                    activeColor: AppColors.primary,
                                    onChanged: (_) => controller.toggleParticipant(p.id),
                                  ),
                                  Expanded(
                                    child: Text(
                                      p.id == 'user_me' ? '${p.name} (You)' : p.name,
                                      style: AppTextStyles.bodyMedium(isDark: isDark)
                                          .copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),

                                  // Split details widget depending on mode
                                  if (controller.selectedSplitType.value == SplitType.equal)
                                    Text(
                                      isIncluded ? '\$${shareVal.toStringAsFixed(2)}' : '\$0.00',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: isIncluded ? AppColors.primary : Colors.grey,
                                      ),
                                    )
                                  else if (controller.selectedSplitType.value == SplitType.unequal)
                                    SizedBox(
                                      width: 100.w,
                                      child: TextField(
                                        controller: controller.customShareControllers[p.id],
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          prefixText: '\$',
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        ),
                                        onChanged: (_) => controller.update(),
                                      ),
                                    )
                                  else if (controller.selectedSplitType.value == SplitType.percentage)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 70.w,
                                          child: TextField(
                                            controller: controller.customShareControllers[p.id],
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                              suffixText: '%',
                                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                            ),
                                            onChanged: (_) => controller.update(),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          '(\$${shareVal.toStringAsFixed(2)})',
                                          style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  SizedBox(height: 20.h),

                  // Receipt Upload Section
                  Text('Attach Receipt Photo', style: AppTextStyles.label(isDark: isDark)),
                  SizedBox(height: 8.h),
                  Obx(
                    () {
                      final path = controller.receiptImagePath.value;
                      if (path != null && path.isNotEmpty) {
                        return Stack(
                          children: [
                            Container(
                              height: 160.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                image: DecorationImage(
                                  image: FileImage(File(path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () => controller.receiptImagePath.value = null,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.pickReceipt(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('Gallery'),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => controller.pickReceipt(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt_outlined),
                              label: const Text('Camera'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 32.h),

                  // Submit Expense Button
                  Obx(
                    () => CustomButton(
                      text: 'Save Expense',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.saveExpense,
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
