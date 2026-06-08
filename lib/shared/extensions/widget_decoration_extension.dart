import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

extension StyledWidgetDecoration on Widget {
  Widget backgroundColor(Color color, {bool animate = false}) => DecoratedBox(
    decoration: BoxDecoration(color: color),
    child: this,
  );

  Widget backgroundImage(DecorationImage image, {bool animate = false}) =>
      DecoratedBox(
        decoration: BoxDecoration(image: image),
        child: this,
      );

  Widget backgroundGradient(Gradient gradient, {bool animate = false}) =>
      DecoratedBox(
        decoration: BoxDecoration(gradient: gradient),
        child: this,
      );

  Widget backgroundLinearGradient({
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
    List<Color>? colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
    bool animate = false,
  }) {
    BoxDecoration decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: colors ?? [],
        stops: stops,
        tileMode: tileMode,
        transform: transform,
      ),
    );
    return DecoratedBox(
      decoration: decoration,
      child: this,
    );
  }

  Widget backgroundRadialGradient({
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
    List<Color>? colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    AlignmentGeometry? focal,
    double focalRadius = 0.0,
    GradientTransform? transform,
    bool animate = false,
  }) {
    BoxDecoration decoration = BoxDecoration(
      gradient: RadialGradient(
        center: center,
        radius: radius,
        colors: colors ?? [],
        stops: stops,
        tileMode: tileMode,
        focal: focal,
        focalRadius: focalRadius,
        transform: transform,
      ),
    );
    return DecoratedBox(
      decoration: decoration,
      child: this,
    );
  }

  Widget backgroundSweepGradient({
    AlignmentGeometry center = Alignment.center,
    double startAngle = 0.0,
    double endAngle = pi * 2,
    List<Color>? colors,
    List<double>? stops,
    TileMode tileMode = TileMode.clamp,
    GradientTransform? transform,
    bool animate = false,
  }) {
    BoxDecoration decoration = BoxDecoration(
      gradient: SweepGradient(
        center: center,
        startAngle: startAngle,
        endAngle: endAngle,
        colors: colors ?? [],
        stops: stops,
        tileMode: tileMode,
        transform: transform,
      ),
    );
    return DecoratedBox(
      decoration: decoration,
      child: this,
    );
  }

  Widget backgroundBlendMode(BlendMode blendMode, {bool animate = false}) =>
      DecoratedBox(
        decoration: BoxDecoration(backgroundBlendMode: blendMode),
        child: this,
      );

  Widget backgroundBlur(
    double sigma, {
    bool animate = false,
  }) => BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: sigma,
      sigmaY: sigma,
    ),
    child: this,
  );

  Widget borderRadius({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
    bool animate = false,
  }) {
    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(topLeft ?? all ?? 0.0),
        topRight: Radius.circular(topRight ?? all ?? 0.0),
        bottomLeft: Radius.circular(bottomLeft ?? all ?? 0.0),
        bottomRight: Radius.circular(bottomRight ?? all ?? 0.0),
      ),
    );
    return DecoratedBox(
      decoration: decoration,
      child: this,
    );
  }

  Widget borderRadiusDirectional({
    double? all,
    double? topStart,
    double? topEnd,
    double? bottomStart,
    double? bottomEnd,
    bool animate = false,
  }) {
    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadiusDirectional.only(
        topStart: Radius.circular(topStart ?? all ?? 0.0),
        topEnd: Radius.circular(topEnd ?? all ?? 0.0),
        bottomStart: Radius.circular(bottomStart ?? all ?? 0.0),
        bottomEnd: Radius.circular(bottomEnd ?? all ?? 0.0),
      ),
    );
    return DecoratedBox(
      decoration: decoration,
      child: this,
    );
  }

  Widget border({
    double? all,
    double? left,
    double? right,
    double? top,
    double? bottom,
    Color color = const Color(0xFF000000),
    BorderStyle style = BorderStyle.solid,
    bool animate = false,
  }) {
    BoxDecoration decoration = BoxDecoration(
      border: Border(
        left:
            (left ?? all) == null
                ? BorderSide.none
                : BorderSide(
                  color: color,
                  width: left ?? all ?? 0,
                  style: style,
                ),
        right:
            (right ?? all) == null
                ? BorderSide.none
                : BorderSide(
                  color: color,
                  width: right ?? all ?? 0,
                  style: style,
                ),
        top:
            (top ?? all) == null
                ? BorderSide.none
                : BorderSide(
                  color: color,
                  width: top ?? all ?? 0,
                  style: style,
                ),
        bottom:
            (bottom ?? all) == null
                ? BorderSide.none
                : BorderSide(
                  color: color,
                  width: bottom ?? all ?? 0,
                  style: style,
                ),
      ),
    );
    return DecoratedBox(
      decoration: decoration,
      child: this,
    );
  }

  Widget decorated({
    Color? color,
    DecorationImage? image,
    BoxBorder? border,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    BlendMode? backgroundBlendMode,
    BoxShape shape = BoxShape.rectangle,
    DecorationPosition position = DecorationPosition.background,
    bool animate = false,
  }) {
    BoxDecoration decoration = BoxDecoration(
      color: color,
      image: image,
      border: border,
      borderRadius: borderRadius,
      boxShadow: boxShadow,
      gradient: gradient,
      backgroundBlendMode: backgroundBlendMode,
      shape: shape,
    );
    return DecoratedBox(
      decoration: decoration,
      position: position,
      child: this,
    );
  }

  Widget elevation(
    double elevation, {
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    Color shadowColor = const Color(0xFF000000),
  }) => Material(
    color: Colors.transparent,
    elevation: elevation,
    borderRadius: borderRadius,
    shadowColor: shadowColor,
    child: this,
  );

  Widget boxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
    bool animate = false,
  }) {
    BoxDecoration decoration = BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: color,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
          offset: offset,
        ),
      ],
    );
    return DecoratedBox(
      decoration: decoration,
      child: this,
    );
  }

  Widget opacity(
    double opacity, {
    bool animate = false,
    bool alwaysIncludeSemantics = false,
  }) => Opacity(
    opacity: opacity,
    alwaysIncludeSemantics: alwaysIncludeSemantics,
    child: this,
  );
}
