import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/responsive_layout.dart';
import '../home/home_screen.dart';
import '../trips/trips_screen.dart';
import '../profile/profile_screen.dart';
import 'main_navigation_controller.dart';

class MainNavigationScreen extends GetView<MainNavigationController> {
  const MainNavigationScreen({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    TripsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog(context);
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: ResponsiveLayout(
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
                  icon: Icon(Icons.card_travel_outlined),
                  activeIcon: Icon(Icons.card_travel_rounded),
                  label: 'Trips',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),

        // Tablet / Desktop View (>= 600px width): Side Navigation Rail
        tablet: _buildDesktopLayout(context, isDark, isDesktop: false),
        desktop: _buildDesktopLayout(context, isDark, isDesktop: isDesktop),
      ),
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
              minExtendedWidth: 180,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/logos/logo.png',
                      width: 32,
                      height: 32,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.flight_takeoff_rounded,
                        size: 28,
                        color: AppColors.primary,
                      ),
                    ),
                    if (isDesktop) ...[
                      const SizedBox(width: 10),
                      const Text(
                        'SplitEasy',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 18,
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
                  icon: Icon(Icons.home_outlined, size: 20),
                  selectedIcon: Icon(Icons.home_rounded, size: 20),
                  label: Text('Home', style: TextStyle(fontSize: 14)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.card_travel_outlined, size: 20),
                  selectedIcon: Icon(Icons.card_travel_rounded, size: 20),
                  label: Text('Trips', style: TextStyle(fontSize: 14)),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline, size: 20),
                  selectedIcon: Icon(Icons.person_rounded, size: 20),
                  label: Text('Profile', style: TextStyle(fontSize: 14)),
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
      ),
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.power_settings_new_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Exit SplitEasy?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to close the application?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Exit App',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
