import 'package:flutter/material.dart';

extension StyledWidgetPadding on Widget {
  Widget padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool animate = false,
  }) => Padding(
    padding: EdgeInsets.only(
      top: top ?? vertical ?? all ?? 0.0,
      bottom: bottom ?? vertical ?? all ?? 0.0,
      left: left ?? horizontal ?? all ?? 0.0,
      right: right ?? horizontal ?? all ?? 0.0,
    ),
    child: this,
  );

  Widget paddingDirectional({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? start,
    double? end,
    bool animate = false,
  }) => Padding(
    padding: EdgeInsetsDirectional.only(
      top: top ?? vertical ?? all ?? 0.0,
      bottom: bottom ?? vertical ?? all ?? 0.0,
      start: start ?? horizontal ?? all ?? 0.0,
      end: end ?? horizontal ?? all ?? 0.0,
    ),
    child: this,
  );

  Widget paddingAll(double padding) =>
      Padding(padding: EdgeInsets.all(padding), child: this);

  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => Padding(
    padding: EdgeInsets.only(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
    ),
    child: this,
  );
}
