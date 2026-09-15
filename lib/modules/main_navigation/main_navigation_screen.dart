import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/responsive_layout.dart';
import '../home/home_screen.dart';
import '../groups/groups_screen.dart';
import '../balances/balances_screen.dart';
import '../friends/friends_screen.dart';
import '../activity/activity_screen.dart';
import '../profile/profile_screen.dart';
import 'main_navigation_controller.dart';

class MainNavigationScreen extends GetView<MainNavigationController> {
  const MainNavigationScreen({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    GroupsScreen(),
    BalancesScreen(),
    FriendsScreen(),
    ActivityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveLayout(
      // Mobile View (<600px width): Bottom Navigation Bar
      mobile: Obx(
        () => Scaffold(
          body: IndexedStack(
            index: controller.currentIndex.value,
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group_outlined),
                activeIcon: Icon(Icons.group_rounded),
                label: 'Groups',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Balances',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Friends',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history_rounded),
                label: 'Activity',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'main_mobile_fab',
            onPressed: controller.goToAddExpense,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.add, color: Colors.white, size: 28.sp),
          ),
        ),
      ),

      // Tablet / Desktop View (>= 600px width): Side Navigation Rail
      tablet: _buildDesktopLayout(context, isDark, isDesktop: false),
      desktop: _buildDesktopLayout(context, isDark, isDesktop: true),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark, {required bool isDesktop}) {
    return Obx(
      () => Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: controller.currentIndex.value,
              onDestinationSelected: controller.changePage,
              extended: isDesktop,
              minExtendedWidth: 200,
              leading: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logos/logo.png',
                      width: 36.w,
                      height: 36.w,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.call_split_rounded,
                        size: 32.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    if (isDesktop) ...[
                      SizedBox(width: 12.w),
                      Text(
                        'SplitEasy',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.group_outlined),
                  selectedIcon: Icon(Icons.group_rounded),
                  label: Text('Groups'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                  label: Text('Balances'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people_rounded),
                  label: Text('Friends'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.history_outlined),
                  selectedIcon: Icon(Icons.history_rounded),
                  label: Text('Activity'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: controller.currentIndex.value,
                children: _pages,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'main_desktop_fab',
          onPressed: controller.goToAddExpense,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Expense', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
