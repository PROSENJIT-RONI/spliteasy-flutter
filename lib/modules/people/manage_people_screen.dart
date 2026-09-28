import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/loading_indicator.dart';
import 'manage_people_controller.dart';

class ManagePeopleScreen extends GetView<ManagePeopleController> {
  const ManagePeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Participants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => controller.openAddDialog(context),
            tooltip: 'Add Participant',
          ),
          SizedBox(width: isDesktop ? 8.0 : 8.w),
        ],
      ),
      body: SafeArea(
        child: Obx(
          () {
            if (controller.isLoading.value && controller.people.isEmpty) {
              return const LoadingIndicator(message: 'Loading participants...');
            }

            if (controller.people.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: isDesktop ? 56.0 : 64.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                    SizedBox(height: isDesktop ? 16.0 : 16.h),
                    Text(
                      'No Participants Added',
                      style: AppTextStyles.h3(isDark: isDark),
                    ),
                    SizedBox(height: isDesktop ? 8.0 : 8.h),
                    Text(
                      'Add trip participants to start recording expenses',
                      style: AppTextStyles.bodySmall(isDark: isDark),
                    ),
                    SizedBox(height: isDesktop ? 20.0 : 20.h),
                    ElevatedButton.icon(
                      onPressed: () => controller.openAddDialog(context),
                      icon: const Icon(Icons.person_add_rounded),
                      label: const Text('Add Participant'),
                    ),
                  ],
                ),
              );
            }

            return CenteredContentWrapper(
              maxWidth: 600,
              child: ListView.builder(
                padding: EdgeInsets.all(isDesktop ? 20.0 : 16.r),
                itemCount: controller.people.length,
                itemBuilder: (context, index) {
                  final person = controller.people[index];

                  return Card(
                    margin: EdgeInsets.only(bottom: isDesktop ? 10.0 : 10.h),
                    child: Padding(
                      padding: EdgeInsets.all(isDesktop ? 12.0 : 12.r),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              person.name.isNotEmpty ? person.name[0] : 'P',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: isDesktop ? 12.0 : 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  person.name,
                                  style: AppTextStyles.bodyLarge(isDark: isDark)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                if (person.phone.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    person.phone,
                                    style: AppTextStyles.bodySmall(isDark: isDark),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => controller.openEditDialog(context, person),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 20, color: AppColors.error),
                            onPressed: () => _confirmDeletePerson(context, person),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'manage_people_fab',
        onPressed: () => controller.openAddDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Participant', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _confirmDeletePerson(BuildContext context, person) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Remove ${person.name}?'),
          content: Text(
            'Are you sure you want to remove ${person.name} from this trip?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () {
                Get.back();
                controller.deletePerson(person);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
