import 'package:flutter/material.dart';

extension StyledWidgetClip on Widget {
  Widget clipRRect({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
    CustomClipper<RRect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
    bool animate = false,
  }) => ClipRRect(
    clipper: clipper,
    clipBehavior: clipBehavior,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(topLeft ?? all ?? 0.0),
      topRight: Radius.circular(topRight ?? all ?? 0.0),
      bottomLeft: Radius.circular(bottomLeft ?? all ?? 0.0),
      bottomRight: Radius.circular(bottomRight ?? all ?? 0.0),
    ),
    child: this,
  );

  Widget clipRect({
    CustomClipper<Rect>? clipper,
    Clip clipBehavior = Clip.hardEdge,
  }) => ClipRect(
    clipper: clipper,
    clipBehavior: clipBehavior,
    child: this,
  );

  Widget clipOval() => ClipOval(
    child: this,
  );
}
