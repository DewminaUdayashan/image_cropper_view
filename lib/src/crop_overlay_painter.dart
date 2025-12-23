import 'package:flutter/material.dart';

import 'cropper_style.dart';

class CropOverlayPainter extends CustomPainter {
  final Rect imageRect;
  final Rect cropRect;
  final CropperStyle style;

  CropOverlayPainter({
    required this.imageRect,
    required this.cropRect,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Update (Semi-transparent background everywhere EXCEPT the crop rect)
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path cropPath = Path()..addRect(cropRect);

    // Reverse difference to cut out the hole
    final Path overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cropPath,
    );

    canvas.drawPath(overlayPath, Paint()..color = style.overlayColor);

    // 2. Draw Border around Crop Rect
    final Paint borderPaint = Paint()
      ..color = style.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.borderWidth;

    canvas.drawRect(cropRect, borderPaint);

    // 3. Draw Handles (Corners)
    final Paint handlePaint = Paint()..color = style.handlerColor;
    final double handleSize = style.handlerSize / 2;

    // Top Left
    canvas.drawCircle(cropRect.topLeft, handleSize, handlePaint);
    // Top Right
    canvas.drawCircle(cropRect.topRight, handleSize, handlePaint);
    // Bottom Left
    canvas.drawCircle(cropRect.bottomLeft, handleSize, handlePaint);
    // Bottom Right
    canvas.drawCircle(cropRect.bottomRight, handleSize, handlePaint);
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.imageRect != imageRect;
  }
}
