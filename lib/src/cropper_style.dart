import 'package:flutter/material.dart';

enum HandleType { circle, corner }

class CropperStyle {
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;
  final Color handlerColor;
  final double handlerSize;
  final HandleType handleType;
  final double handlerThickness;
  final double cropBorderRadius;
  final bool enableFeedback;
  final bool enableScaleAnimation;
  final double activeHandlerScale;

  const CropperStyle({
    this.overlayColor = const Color.fromARGB(150, 0, 0, 0),
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.handlerColor = Colors.white,
    this.handlerSize = 20.0,
    this.handleType = HandleType.circle,
    this.handlerThickness = 4.0,
    this.cropBorderRadius = 12.0,
    this.enableFeedback = true,
    this.enableScaleAnimation = true,
    this.activeHandlerScale = 1.3,
  });
}
