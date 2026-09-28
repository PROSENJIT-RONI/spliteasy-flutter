import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final effectiveHeight = height ?? (isDesktop ? 48.0 : 50.h);
    final effectiveWidth = width ?? double.infinity;
    final radius = isDesktop ? 12.0 : 12.r;
    final iconSize = isDesktop ? 20.0 : 20.sp;

    if (isOutlined) {
      return SizedBox(
        width: effectiveWidth,
        height: effectiveHeight,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: backgroundColor ?? AppColors.primary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: _buildChild(
            color: textColor ?? backgroundColor ?? AppColors.primary,
            isDesktop: isDesktop,
            iconSize: iconSize,
          ),
        ),
      );
    }

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0,
        ),
        child: _buildChild(
          color: textColor ?? Colors.white,
          isDesktop: isDesktop,
          iconSize: iconSize,
        ),
      ),
    );
  }

  Widget _buildChild({
    required Color color,
    required bool isDesktop,
    required double iconSize,
  }) {
    if (isLoading) {
      final spinnerSize = isDesktop ? 22.0 : 24.w;
      return SizedBox(
        width: spinnerSize,
        height: spinnerSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: iconSize),
          SizedBox(width: isDesktop ? 8.0 : 8.w),
          Text(
            text,
            style: AppTextStyles.button(color: color),
          ),
        ],
      );
    }

    return Text(
      text,
      style: AppTextStyles.button(color: color),
    );
  }
}
