import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../data/models/trip_expense_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/responsive_layout.dart';
import 'add_expense_controller.dart';

class AddExpenseScreen extends GetView<AddExpenseController> {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = controller.existingExpense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
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
                  // Description
                  CustomTextField(
                    label: 'Expense Description *',
                    hintText: 'e.g. Dinner, Taxi, Resort',
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

                  // Amount & Date Row
                  Row(
                    children: [
                      // Amount
                      Expanded(
                        child: CustomTextField(
                          label: 'Total Amount (₹) *',
                          hintText: '0.00',
                          controller: controller.amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: Icon(Icons.currency_rupee_rounded, size: 20.sp),
                          onChanged: (_) => controller.update(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // Date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date', style: AppTextStyles.label(isDark: isDark)),
                            SizedBox(height: 6.h),
                            Obx(
                              () => InkWell(
                                onTap: () => _selectDate(context),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 18.sp, color: AppColors.primary),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          DateFormat('dd/MM/yyyy').format(controller.expenseDate.value),
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

                  // Paid By Dropdown
                  Text('Paid By *', style: AppTextStyles.label(isDark: isDark)),
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
                          value: controller.selectedPaidByPersonId.value.isNotEmpty
                              ? controller.selectedPaidByPersonId.value
                              : null,
                          hint: const Text('Select who paid'),
                          isExpanded: true,
                          dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          items: controller.tripPeople.map((p) {
                            return DropdownMenuItem<String>(
                              value: p.id,
                              child: Text(
                                p.name,
                                style: AppTextStyles.bodyMedium(isDark: isDark),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedPaidByPersonId.value = val;
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
                        controller.update();
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Participants List & Live Shares Preview
                  Text('Expense Participants', style: AppTextStyles.label(isDark: isDark)),
                  SizedBox(height: 8.h),
                  Obx(
                    () {
                      final splitsData = controller.calculateSplitsData();
                      final splitsMap = {
                        for (var s in splitsData) s['person_id'] as String: s['share_amount'] as double
                      };

                      return Column(
                        children: controller.tripPeople.map((person) {
                          final isIncluded =
                              controller.selectedParticipantIds.contains(person.id);
                          final shareVal = splitsMap[person.id] ?? 0.0;

                          return Card(
                            margin: EdgeInsets.only(bottom: 8.h),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: isIncluded,
                                    activeColor: AppColors.primary,
                                    onChanged: (_) => controller.toggleParticipant(person.id),
                                  ),
                                  Expanded(
                                    child: Text(
                                      person.name,
                                      style: AppTextStyles.bodyMedium(isDark: isDark)
                                          .copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),

                                  // Shares UI per mode
                                  if (controller.selectedSplitType.value == SplitType.equal)
                                    Text(
                                      isIncluded ? '₹${shareVal.toStringAsFixed(2)}' : '₹0.00',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: isIncluded ? AppColors.primary : Colors.grey,
                                      ),
                                    )
                                  else if (controller.selectedSplitType.value == SplitType.unequal)
                                    SizedBox(
                                      width: 110.w,
                                      child: TextField(
                                        controller: controller.customShareControllers[person.id],
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          prefixText: '₹',
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
                                            controller: controller.customShareControllers[person.id],
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
                                          '(₹${shareVal.toStringAsFixed(2)})',
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
                  SizedBox(height: 16.h),

                  // Note Field
                  CustomTextField(
                    label: 'Note (Optional)',
                    hintText: 'e.g. Paid via UPI',
                    controller: controller.noteController,
                    prefixIcon: Icon(Icons.note_alt_outlined, size: 20.sp),
                  ),
                  SizedBox(height: 32.h),

                  // Submit Button
                  Obx(
                    () => CustomButton(
                      text: isEditing ? 'Update Expense' : 'Save Expense',
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

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.expenseDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      controller.expenseDate.value = picked;
    }
  }
}
