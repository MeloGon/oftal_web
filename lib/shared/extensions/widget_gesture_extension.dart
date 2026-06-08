import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef GestureOnTapChangeCallback = void Function(bool tapState);

extension StyledWidgetGesture on Widget {
  Widget parent(Widget Function({required Widget child}) parent) =>
      parent(child: this);

  Widget gestures({
    GestureOnTapChangeCallback? onTapChange,
    GestureTapDownCallback? onTapDown,
    GestureTapUpCallback? onTapUp,
    GestureTapCallback? onTap,
    GestureTapCancelCallback? onTapCancel,
    GestureTapDownCallback? onSecondaryTapDown,
    GestureTapUpCallback? onSecondaryTapUp,
    GestureTapCancelCallback? onSecondaryTapCancel,
    GestureTapCallback? onDoubleTap,
    GestureLongPressCallback? onLongPress,
    GestureLongPressStartCallback? onLongPressStart,
    GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate,
    GestureLongPressUpCallback? onLongPressUp,
    GestureLongPressEndCallback? onLongPressEnd,
    GestureDragDownCallback? onVerticalDragDown,
    GestureDragStartCallback? onVerticalDragStart,
    GestureDragUpdateCallback? onVerticalDragUpdate,
    GestureDragEndCallback? onVerticalDragEnd,
    GestureDragCancelCallback? onVerticalDragCancel,
    GestureDragDownCallback? onHorizontalDragDown,
    GestureDragStartCallback? onHorizontalDragStart,
    GestureDragUpdateCallback? onHorizontalDragUpdate,
    GestureDragEndCallback? onHorizontalDragEnd,
    GestureDragCancelCallback? onHorizontalDragCancel,
    GestureDragDownCallback? onPanDown,
    GestureDragStartCallback? onPanStart,
    GestureDragUpdateCallback? onPanUpdate,
    GestureDragEndCallback? onPanEnd,
    GestureDragCancelCallback? onPanCancel,
    GestureScaleStartCallback? onScaleStart,
    GestureScaleUpdateCallback? onScaleUpdate,
    GestureScaleEndCallback? onScaleEnd,
    GestureForcePressStartCallback? onForcePressStart,
    GestureForcePressPeakCallback? onForcePressPeak,
    GestureForcePressUpdateCallback? onForcePressUpdate,
    GestureForcePressEndCallback? onForcePressEnd,
    HitTestBehavior? behavior,
    bool excludeFromSemantics = false,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) => GestureDetector(
    onTapDown: (TapDownDetails tapDownDetails) {
      if (onTapDown != null) onTapDown(tapDownDetails);
      if (onTapChange != null) onTapChange(true);
    },
    onTapCancel: () {
      if (onTapCancel != null) onTapCancel();
      if (onTapChange != null) onTapChange(false);
    },
    onTap: () {
      if (onTap != null) onTap();
      if (onTapChange != null) onTapChange(false);
    },
    onTapUp: onTapUp,
    onDoubleTap: onDoubleTap,
    onLongPress: onLongPress,
    onLongPressStart: onLongPressStart,
    onLongPressEnd: onLongPressEnd,
    onLongPressMoveUpdate: onLongPressMoveUpdate,
    onLongPressUp: onLongPressUp,
    onVerticalDragStart: onVerticalDragStart,
    onVerticalDragEnd: onVerticalDragEnd,
    onVerticalDragDown: onVerticalDragDown,
    onVerticalDragCancel: onVerticalDragCancel,
    onVerticalDragUpdate: onVerticalDragUpdate,
    onHorizontalDragStart: onHorizontalDragStart,
    onHorizontalDragEnd: onHorizontalDragEnd,
    onHorizontalDragCancel: onHorizontalDragCancel,
    onHorizontalDragUpdate: onHorizontalDragUpdate,
    onHorizontalDragDown: onHorizontalDragDown,
    onForcePressStart: onForcePressStart,
    onForcePressEnd: onForcePressEnd,
    onForcePressPeak: onForcePressPeak,
    onForcePressUpdate: onForcePressUpdate,
    onPanStart: onPanStart,
    onPanEnd: onPanEnd,
    onPanCancel: onPanCancel,
    onPanDown: onPanDown,
    onPanUpdate: onPanUpdate,
    onScaleStart: onScaleStart,
    onScaleEnd: onScaleEnd,
    onScaleUpdate: onScaleUpdate,
    behavior: behavior,
    excludeFromSemantics: excludeFromSemantics,
    dragStartBehavior: dragStartBehavior,
    child: this,
  );

  Widget ripple({
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    InteractiveInkFeatureFactory? splashFactory,
    double? radius,
    ShapeBorder? customBorder,
    bool enableFeedback = true,
    bool excludeFromSemantics = false,
    FocusNode? focusNode,
    bool canRequestFocus = true,
    bool autoFocus = false,
  }) => Builder(
    builder: (BuildContext context) {
      GestureDetector? gestures =
          context.findAncestorWidgetOfExactType<GestureDetector>();
      return Material(
        color: Colors.transparent,
        child: InkWell(
          focusColor: focusColor,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          splashFactory: splashFactory,
          radius: radius,
          customBorder: customBorder,
          enableFeedback: enableFeedback,
          excludeFromSemantics: excludeFromSemantics,
          focusNode: focusNode,
          canRequestFocus: canRequestFocus,
          autofocus: autoFocus,
          onTap: gestures?.onTap,
          child: this,
        ),
      );
    },
  );

  Widget inkWell({
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
  }) => InkWell(
    onLongPress: onLongPress,
    highlightColor: Colors.transparent,
    splashFactory: NoSplash.splashFactory,
    onTap: onTap,
    child: this,
  );

  Widget onLongPressTap({GestureLongPressCallback? onLongPress}) => InkWell(
    onLongPress: onLongPress,
    child: this,
  );

  Widget semanticsLabel(String label) => Semantics.fromProperties(
    properties: SemanticsProperties(label: label),
    child: this,
  );
}
