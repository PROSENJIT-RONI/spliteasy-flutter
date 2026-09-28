import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/theme/app_colors.dart';
import 'splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller; // Access controller instance
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final logoSize = isDesktop ? 100.0 : 120.w;
    final logoIconSize = isDesktop ? 50.0 : 60.sp;
    final titleFontSize = isDesktop ? 32.0 : 32.sp;
    final subtitleFontSize = isDesktop ? 14.0 : 14.sp;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 24.0 : 24.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(isDesktop ? 18.0 : 20.r),
                    child: Image.asset(
                      'assets/logos/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.flight_takeoff_rounded,
                        size: logoIconSize,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isDesktop ? 20.0 : 24.h),
                Text(
                  'SplitEasy',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: isDesktop ? 6.0 : 8.h),
                Text(
                  'Trip Expense Manager for Admins',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: subtitleFontSize,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: isDesktop ? 36.0 : 48.h),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
