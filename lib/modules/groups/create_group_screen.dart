import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/responsive_layout.dart';
import 'create_group_controller.dart';

class CreateGroupScreen extends GetView<CreateGroupController> {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Group'),
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
                  // Emoji Picker & Group Name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji Selector
                      Obx(
                        () => GestureDetector(
                          onTap: () => _showEmojiPicker(context),
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.primary, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                controller.selectedEmoji.value,
                                style: TextStyle(fontSize: 28.sp),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: CustomTextField(
                          label: 'Group Name',
                          hintText: 'e.g. Summer Goa Trip',
                          controller: controller.nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a group name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Category Selector
                  Text('Category', style: AppTextStyles.label(isDark: isDark)),
                  SizedBox(height: 8.h),
                  Obx(
                    () => Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: controller.categoryOptions.map((cat) {
                        final isSelected = controller.selectedCategory.value == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) controller.selectedCategory.value = cat;
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Description
                  CustomTextField(
                    label: 'Description (Optional)',
                    hintText: 'e.g. Rent, food and activities',
                    controller: controller.descriptionController,
                    maxLines: 2,
                  ),
                  SizedBox(height: 24.h),

                  // Add Members Section
                  Text('Add Members', style: AppTextStyles.h3(isDark: isDark)),
                  SizedBox(height: 12.h),
                  Obx(
                    () => Column(
                      children: controller.availableFriends.map((friend) {
                        return Obx(
                          () {
                            final isSelected = controller.selectedMemberIds.contains(friend.id);
                            return Card(
                              margin: EdgeInsets.only(bottom: 8.h),
                              child: CheckboxListTile(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                title: Text(
                                  friend.name,
                                  style: AppTextStyles.bodyMedium(isDark: isDark).copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  friend.phone,
                                  style: AppTextStyles.bodySmall(isDark: isDark),
                                ),
                                secondary: CircleAvatar(
                                  backgroundColor: AppColors.primaryLight,
                                  child: Text(
                                    friend.name[0],
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onChanged: (_) => controller.toggleMember(friend.id),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Create Button
                  Obx(
                    () => CustomButton(
                      text: 'Create Group',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.createGroup,
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

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Group Icon', style: AppTextStyles.h3()),
              SizedBox(height: 16.h),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: controller.emojiOptions.length,
                itemBuilder: (context, index) {
                  final emoji = controller.emojiOptions[index];
                  return GestureDetector(
                    onTap: () {
                      controller.selectedEmoji.value = emoji;
                      Get.back();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: 32.sp),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
