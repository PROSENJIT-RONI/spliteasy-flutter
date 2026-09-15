import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import 'friends_controller.dart';

class FriendsScreen extends GetView<FriendsController> {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => _showAddFriendDialog(context),
            tooltip: 'Add Friend',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value && controller.friends.isEmpty) {
            return const LoadingIndicator(message: 'Loading friends...');
          }

          if (controller.friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline_rounded,
                    size: 64.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No Friends Added Yet',
                    style: AppTextStyles.h3(isDark: isDark),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Add friends by phone number to split bills directly',
                    style: AppTextStyles.bodySmall(isDark: isDark),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton.icon(
                    onPressed: () => _showAddFriendDialog(context),
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Add Friend'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchFriends,
            color: AppColors.primary,
            child: CenteredContentWrapper(
              maxWidth: 800,
              child: ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: controller.friends.length,
                itemBuilder: (context, index) {
                  final friend = controller.friends[index];

                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12.r),
                      leading: CircleAvatar(
                        radius: 24.r,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          friend.name[0],
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        friend.name,
                        style: AppTextStyles.bodyLarge(isDark: isDark)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        friend.phone,
                        style: AppTextStyles.bodySmall(isDark: isDark),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_card_rounded, color: AppColors.primary),
                        tooltip: 'Split Expense',
                        onPressed: () => controller.goToAddExpenseWithFriend(friend),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'friends_fab',
        onPressed: () => _showAddFriendDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Friend', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Add Friend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'Phone Number',
                hintText: 'e.g. +1 555-0188',
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            Obx(
              () => CustomButton(
                text: 'Add',
                width: 100.w,
                height: 40.h,
                isLoading: controller.isLoading.value,
                onPressed: controller.addFriend,
              ),
            ),
          ],
        );
      },
    );
  }
}
