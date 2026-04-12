import 'package:flutter/widgets.dart';

abstract final class Breakpoints {
  /// < 600 — мобиль
  static const double mobile = 600;
  /// 600..1024 — планшет
  static const double tablet = 1024;
}

extension BreakpointsContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.tablet;

  /// Возвращает одно из значений в зависимости от ширины экрана.
  T responsive<T>({required T mobile, T? tablet, required T desktop}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet ?? desktop;
    return desktop;
  }
}
