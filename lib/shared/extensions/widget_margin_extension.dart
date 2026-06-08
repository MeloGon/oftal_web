import 'package:flutter/material.dart';

/// Add margin property to widget
extension WidgetMarginX on Widget {
  Widget marginAll(double margin) =>
      Container(margin: EdgeInsets.all(margin), child: this);

  // Widget marginSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
  //     Container(
  //         margin:
  //         EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
  //         child: this);

  Widget marginOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => Container(
    margin: EdgeInsets.only(top: top, left: left, right: right, bottom: bottom),
    child: this,
  );

  Widget get marginZero => Container(margin: EdgeInsets.zero, child: this);
}

/// Allows you to insert widgets inside a CustomScrollView
extension WidgetSliverBoxX on Widget {
  Widget get sliverBox => SliverToBoxAdapter(child: this);
}
