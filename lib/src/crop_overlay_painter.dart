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

    // Create RRect from cropRect using style.cropBorderRadius
    final RRect cropRRect = RRect.fromRectAndRadius(
      cropRect,
      Radius.circular(style.cropBorderRadius),
    );

    final Path cropPath = Path()..addRRect(cropRRect);

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

    canvas.drawRRect(cropRRect, borderPaint);

    // 3. Draw Handles (Corners)
    final Paint handlePaint = Paint()
      ..color = style.handlerColor
      ..strokeCap = StrokeCap.round; // Round caps for corner lines

    if (style.handleType == HandleType.corner) {
      handlePaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.handlerThickness;

      final double handleLen = style.handlerSize;
      final double radius = style.cropBorderRadius;

      // Top Left
      final Path topLeft = Path()
        ..moveTo(cropRect.left, cropRect.top + handleLen)
        ..lineTo(cropRect.left, cropRect.top + radius)
        ..arcToPoint(
          Offset(cropRect.left + radius, cropRect.top),
          radius: Radius.circular(radius),
        )
        ..lineTo(cropRect.left + handleLen, cropRect.top);
      canvas.drawPath(topLeft, handlePaint);

      // Top Right
      final Path topRight = Path()
        ..moveTo(cropRect.right - handleLen, cropRect.top)
        ..lineTo(cropRect.right - radius, cropRect.top)
        ..arcToPoint(
          Offset(cropRect.right, cropRect.top + radius),
          radius: Radius.circular(radius),
        )
        ..lineTo(cropRect.right, cropRect.top + handleLen);
      canvas.drawPath(topRight, handlePaint);

      // Bottom Right
      final Path bottomRight = Path()
        ..moveTo(cropRect.right, cropRect.bottom - handleLen)
        ..lineTo(cropRect.right, cropRect.bottom - radius)
        ..arcToPoint(
          Offset(cropRect.right - radius, cropRect.bottom),
          radius: Radius.circular(radius),
        )
        ..lineTo(cropRect.right - handleLen, cropRect.bottom);
      canvas.drawPath(bottomRight, handlePaint);

      // Bottom Left
      final Path bottomLeft = Path()
        ..moveTo(cropRect.left + handleLen, cropRect.bottom)
        ..lineTo(cropRect.left + radius, cropRect.bottom)
        ..arcToPoint(
          Offset(cropRect.left, cropRect.bottom - radius),
          radius: Radius.circular(radius),
        )
        ..lineTo(cropRect.left, cropRect.bottom - handleLen);
      canvas.drawPath(bottomLeft, handlePaint);
    } else {
      // Circle handles
      handlePaint.style = PaintingStyle.fill;
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
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.imageRect != imageRect;
  }
}
