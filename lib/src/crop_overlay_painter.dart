import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'cropper_style.dart';

/// Identifies which handle or part of the crop area is being interacted with.
enum CropHandleSide {
  /// Top-left corner handle.
  topLeft,

  /// Top-right corner handle.
  topRight,

  /// Bottom-left corner handle.
  bottomLeft,

  /// Bottom-right corner handle.
  bottomRight,

  /// The entire crop rect (for moving/panning).
  move,
}

/// A custom painter that draws the crop overlay, border, and handles.
class CropOverlayPainter extends CustomPainter {
  /// The bounding box of the displayed image.
  final Rect imageRect;

  /// The current crop rectangle.
  final ValueListenable<Rect?> cropRect;

  /// The visual style configuration.
  final CropperStyle style;

  /// The handle currently being interacted with (for highlighting).
  final ValueListenable<CropHandleSide?> activeHandle;

  /// The animation scale for the active handle.
  final ValueListenable<double> scale;

  /// Creates a [CropOverlayPainter].
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
    // FIX: Only draw overlay on top of the image (imageRect), not the full canvas (size).
    // This leaves the padding areas transparent/white.
    final Path backgroundPath = Path()..addRect(imageRect);

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

    // 2. Draw Grid (Rule of Thirds)
    if (style.showGrid) {
      final Paint gridPaint = Paint()
        ..color = style.gridLineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.gridLineThickness;

      // Clip to the rounded crop area
      canvas.save();
      canvas.clipRRect(cropRRect);

      final double width = rect.width;
      final double height = rect.height;

      // Vertical lines
      final double x1 = rect.left + width / 3;
      final double x2 = rect.left + 2 * width / 3;
      canvas.drawLine(Offset(x1, rect.top), Offset(x1, rect.bottom), gridPaint);
      canvas.drawLine(Offset(x2, rect.top), Offset(x2, rect.bottom), gridPaint);

      // Horizontal lines
      final double y1 = rect.top + height / 3;
      final double y2 = rect.top + 2 * height / 3;
      canvas.drawLine(Offset(rect.left, y1), Offset(rect.right, y1), gridPaint);
      canvas.drawLine(Offset(rect.left, y2), Offset(rect.right, y2), gridPaint);

      canvas.restore();
    }

    // 3. Draw Border around Crop Rect
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
