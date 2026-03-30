import 'package:flutter/material.dart';
import 'package:oftal_web/core/constants/breakpoints.dart';

extension ResponsiveContext on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;

  bool get isMobile => width <= Breakpoints.mobile;
  bool get isMobileLarge =>
      width > Breakpoints.mobile && width <= Breakpoints.mobileLarge;
  bool get isTablet =>
      width > Breakpoints.mobileLarge && width < Breakpoints.tablet;
  bool get isDesktop => width >= Breakpoints.tablet;

  T responsiveValue<T>({
    required T mobile,
    T? mobileLarge,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile) return mobile;
    if (isMobileLarge && mobileLarge != null) return mobileLarge;
    if (isTablet && tablet != null) return tablet;
    return desktop;
  }

  double get responsiveWidth {
    if (isMobile) return width * 0.95;
    if (isTablet) return width * 0.85;
    return width * 0.75;
  }
}
