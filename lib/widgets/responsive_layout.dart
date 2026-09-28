import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppResponsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static double fontSize(BuildContext context, double mobileSp, double desktopPx) {
    if (MediaQuery.of(context).size.width >= 600) {
      return desktopPx;
    }
    return mobileSp.sp;
  }

  static double iconSize(BuildContext context, double mobileSp, double desktopPx) {
    if (MediaQuery.of(context).size.width >= 600) {
      return desktopPx;
    }
    return mobileSp.sp;
  }

  static double spacing(BuildContext context, double mobileSp, double desktopPx) {
    if (MediaQuery.of(context).size.width >= 600) {
      return desktopPx;
    }
    return mobileSp.r;
  }

  static T val<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900 && desktop != null) return desktop;
    if (width >= 600 && tablet != null) return tablet;
    if (width >= 600 && desktop != null) return desktop;
    return mobile;
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900 && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        }
        if (constraints.maxWidth >= 600 && desktop != null) {
          return desktop!;
        }
        return mobile;
      },
    );
  }
}

class CenteredContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const CenteredContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
