import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'cropper_style.dart';

enum CropHandleSide { topLeft, topRight, bottomLeft, bottomRight, move }

class CropOverlayPainter extends CustomPainter {
  final Rect imageRect;
  final ValueListenable<Rect?> cropRect;
  final CropperStyle style;
  final ValueListenable<CropHandleSide?> activeHandle;
  final ValueListenable<double> scale;

  CropOverlayPainter({
    required this.imageRect,
    required this.cropRect,
    required this.style,
    required this.activeHandle,
    required this.scale,
  }) : super(repaint: Listenable.merge([cropRect, activeHandle, scale]));

  @override
  void paint(Canvas canvas, Size size) {
    if (cropRect.value == null) return;
    final Rect rect = cropRect.value!;

    // 1. Draw Update (Semi-transparent background everywhere EXCEPT the crop rect)
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create RRect from cropRect using style.cropBorderRadius
    final RRect cropRRect = RRect.fromRectAndRadius(
      rect,
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
      _drawHandle(
        canvas,
        rect.topLeft,
        handlePaint,
        CropHandleSide.topLeft,
        (p) => Path()
          ..moveTo(p.dx, p.dy + handleLen)
          ..lineTo(p.dx, p.dy + radius)
          ..arcToPoint(
            Offset(p.dx + radius, p.dy),
            radius: Radius.circular(radius),
          )
          ..lineTo(p.dx + handleLen, p.dy),
      );

      // Top Right
      _drawHandle(
        canvas,
        rect.topRight,
        handlePaint,
        CropHandleSide.topRight,
        (p) => Path()
          ..moveTo(p.dx - handleLen, p.dy)
          ..lineTo(p.dx - radius, p.dy)
          ..arcToPoint(
            Offset(p.dx, p.dy + radius),
            radius: Radius.circular(radius),
          )
          ..lineTo(p.dx, p.dy + handleLen),
      );

      // Bottom Right
      _drawHandle(
        canvas,
        rect.bottomRight,
        handlePaint,
        CropHandleSide.bottomRight,
        (p) => Path()
          ..moveTo(p.dx, p.dy - handleLen)
          ..lineTo(p.dx, p.dy - radius)
          ..arcToPoint(
            Offset(p.dx - radius, p.dy),
            radius: Radius.circular(radius),
          )
          ..lineTo(p.dx - handleLen, p.dy),
      );

      // Bottom Left
      _drawHandle(
        canvas,
        rect.bottomLeft,
        handlePaint,
        CropHandleSide.bottomLeft,
        (p) => Path()
          ..moveTo(p.dx + handleLen, p.dy)
          ..lineTo(p.dx + radius, p.dy)
          ..arcToPoint(
            Offset(p.dx, p.dy - radius),
            radius: Radius.circular(radius),
          )
          ..lineTo(p.dx, p.dy - handleLen),
      );
    } else {
      // Circle handles
      handlePaint.style = PaintingStyle.fill;
      final double handleSize = style.handlerSize / 2;

      _drawCircleHandle(
        canvas,
        rect.topLeft,
        handleSize,
        handlePaint,
        CropHandleSide.topLeft,
      );
      _drawCircleHandle(
        canvas,
        rect.topRight,
        handleSize,
        handlePaint,
        CropHandleSide.topRight,
      );
      _drawCircleHandle(
        canvas,
        rect.bottomLeft,
        handleSize,
        handlePaint,
        CropHandleSide.bottomLeft,
      );
      _drawCircleHandle(
        canvas,
        rect.bottomRight,
        handleSize,
        handlePaint,
        CropHandleSide.bottomRight,
      );
    }
  }

  void _drawHandle(
    Canvas canvas,
    Offset center,
    Paint paint,
    CropHandleSide side,
    Path Function(Offset) pathBuilder,
  ) {
    canvas.save();
    if (activeHandle.value == side && scale.value > 1.0) {
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale.value);
      canvas.translate(-center.dx, -center.dy);
    }
    canvas.drawPath(pathBuilder(center), paint);
    canvas.restore();
  }

  void _drawCircleHandle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    CropHandleSide side,
  ) {
    canvas.save();
    if (activeHandle.value == side && scale.value > 1.0) {
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale.value);
      canvas.translate(-center.dx, -center.dy);
    }
    canvas.drawCircle(center, radius, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    // The super class handles repainting via the Listenables,
    // but we still check if structural properties changed.
    return oldDelegate.imageRect != imageRect ||
        oldDelegate.style != style ||
        oldDelegate.cropRect != cropRect ||
        oldDelegate.activeHandle != activeHandle ||
        oldDelegate.scale != scale;
  }
}
