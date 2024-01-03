import 'package:flutter/material.dart';

class MenuView extends Drawer {
  MenuView ({Key key, Color backgroundColor, double elevation, ShapeBorder shape, double width, Widget child, String semanticLabel}): super(
    key: key,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    width: width,
    child: child,
    semanticLabel: semanticLabel
  );
}