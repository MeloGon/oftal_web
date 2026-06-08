import 'package:flutter/material.dart';

extension StyledWidgetTransform on Widget {
  Widget rotate({
    required double angle,
    Offset? origin,
    AlignmentGeometry alignment = Alignment.center,
    bool transformHitTests = true,
    bool animate = false,
  }) => Transform.rotate(
    angle: angle,
    alignment: alignment,
    origin: origin,
    transformHitTests: transformHitTests,
    child: this,
  );

  Widget scale({
    double? all,
    double? x,
    double? y,
    Offset? origin,
    AlignmentGeometry alignment = Alignment.center,
    bool transformHitTests = true,
    bool animate = false,
  }) => Transform(
    transform: Matrix4.diagonal3Values(x ?? all ?? 0, y ?? all ?? 0, 1.0),
    alignment: alignment,
    origin: origin,
    transformHitTests: transformHitTests,
    child: this,
  );

  Widget translate({
    required Offset offset,
    bool transformHitTests = true,
    bool animate = false,
  }) => Transform.translate(
    offset: offset,
    transformHitTests: transformHitTests,
    child: this,
  );

  Widget transform({
    required Matrix4 transform,
    Offset? origin,
    AlignmentGeometry? alignment,
    bool transformHitTests = true,
  }) => Transform(
    transform: transform,
    alignment: alignment,
    origin: origin,
    transformHitTests: transformHitTests,
    child: this,
  );
}
