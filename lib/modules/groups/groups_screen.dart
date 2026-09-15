import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import 'groups_controller.dart';

class GroupsScreen extends GetView<GroupsController> {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            onPressed: controller.goToCreateGroup,
            tooltip: 'Create New Group',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const LoadingIndicator(message: 'Loading groups...');
          }

          if (controller.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 64.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No Groups Yet',
                    style: AppTextStyles.h3(isDark: isDark),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Create a group to start splitting bills with friends',
                    style: AppTextStyles.bodySmall(isDark: isDark),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton.icon(
                    onPressed: controller.goToCreateGroup,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Group'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchGroups,
            color: AppColors.primary,
            child: CenteredContentWrapper(
              maxWidth: 800,
              child: ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: controller.groups.length,
                itemBuilder: (context, index) {
                  final group = controller.groups[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12.r),
                      leading: Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            group.icon,
                            style: TextStyle(fontSize: 24.sp),
                          ),
                        ),
                      ),
                      title: Text(
                        group.name,
                        style: AppTextStyles.bodyLarge(isDark: isDark).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          group.description.isNotEmpty
                              ? '${group.description} • ${group.memberIds.length} members'
                              : '${group.memberIds.length} members • ${group.category}',
                          style: AppTextStyles.bodySmall(isDark: isDark),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              group.category,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                      onTap: () => controller.goToGroupDetail(group.id),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'groups_fab',
        onPressed: controller.goToCreateGroup,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Group', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
