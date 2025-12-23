import 'package:flutter/material.dart';

class CropperStyle {
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;
  final Color handlerColor;
  final double handlerSize;

  const CropperStyle({
    this.overlayColor = const Color.fromARGB(150, 0, 0, 0),
    this.borderColor = Colors.white,
    this.borderWidth = 2.0,
    this.handlerColor = Colors.white,
    this.handlerSize = 20.0,
  });
}
