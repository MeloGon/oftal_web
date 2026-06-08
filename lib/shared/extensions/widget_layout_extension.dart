import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

extension StyledWidgetLayout on Widget {
  Widget constrained({
    double? width,
    double? height,
    double minWidth = 0.0,
    double maxWidth = double.infinity,
    double minHeight = 0.0,
    double maxHeight = double.infinity,
    bool animate = false,
  }) {
    BoxConstraints constraints = BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
    constraints =
        (width != null || height != null)
            ? constraints.tighten(width: width, height: height)
            : constraints;
    return ConstrainedBox(
      constraints: constraints,
      child: this,
    );
  }

  Widget width(double width, {bool animate = false}) => ConstrainedBox(
    constraints: BoxConstraints.tightFor(width: width),
    child: this,
  );

  Widget height(double height, {bool animate = false}) => ConstrainedBox(
    constraints: BoxConstraints.tightFor(height: height),
    child: this,
  );

  Widget expanded({
    int flex = 1,
  }) => Expanded(
    flex: flex,
    child: this,
  );

  Widget flexible({
    int flex = 1,
    FlexFit fit = FlexFit.loose,
  }) => Flexible(
    flex: flex,
    fit: fit,
    child: this,
  );

  Widget positioned({
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? width,
    double? height,
  }) => Positioned(
    left: left,
    top: top,
    right: right,
    bottom: bottom,
    width: width,
    height: height,
    child: this,
  );

  Widget positionedDirectional({
    double? start,
    double? end,
    double? top,
    double? bottom,
    double? width,
    double? height,
  }) => PositionedDirectional(
    start: start,
    end: end,
    top: top,
    bottom: bottom,
    width: width,
    height: height,
    child: this,
  );

  Widget alignment(
    AlignmentGeometry alignment, {
    bool animate = false,
  }) => Align(
    alignment: alignment,
    child: this,
  );

  Widget center({
    double? widthFactor,
    double? heightFactor,
  }) => Center(
    widthFactor: widthFactor,
    heightFactor: heightFactor,
    child: this,
  );

  Widget fittedBox({
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
  }) => FittedBox(
    fit: fit,
    alignment: alignment,
    child: this,
  );

  Widget fractionallySizedBox({
    AlignmentGeometry alignment = Alignment.center,
    double? widthFactor,
    double? heightFactor,
  }) => FractionallySizedBox(
    alignment: alignment,
    widthFactor: widthFactor,
    heightFactor: heightFactor,
    child: this,
  );

  Widget aspectRatio({
    required double aspectRatio,
  }) => AspectRatio(
    aspectRatio: aspectRatio,
    child: this,
  );

  Widget overflow({
    AlignmentGeometry alignment = Alignment.center,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) => OverflowBox(
    alignment: alignment,
    minWidth: minWidth,
    maxWidth: minWidth,
    minHeight: minHeight,
    maxHeight: maxHeight,
    child: this,
  );

  Widget offstage({
    bool offstage = true,
  }) => Offstage(
    key: key,
    offstage: offstage,
    child: this,
  );

  Widget scrollable({
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    bool? primary,
    ScrollPhysics? physics,
    ScrollController? controller,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) => SingleChildScrollView(
    scrollDirection: scrollDirection,
    reverse: reverse,
    primary: primary,
    physics: physics,
    controller: controller,
    dragStartBehavior: dragStartBehavior,
    child: this,
  );

  Widget box({
    double? width,
    double? height,
  }) => SizedBox(
    width: width,
    height: height,
    child: this,
  );

  Widget card({
    Color? color,
    double? elevation,
    ShapeBorder? shape,
    bool borderOnForeground = true,
    EdgeInsetsGeometry? margin,
    Clip? clipBehavior,
    bool semanticContainer = true,
  }) => Card(
    color: color,
    elevation: elevation,
    shape: shape,
    borderOnForeground: borderOnForeground,
    margin: margin,
    clipBehavior: clipBehavior,
    semanticContainer: semanticContainer,
    child: this,
  );

  Widget safeArea() => SafeArea(child: this);

  Widget marginSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );
}
