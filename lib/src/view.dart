import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

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

class ImageCropperView extends StatefulWidget {
  final ImageProvider image;
  final double? aspectRatio;
  final CropperStyle style;
  final BoxDecoration? decoration;

  const ImageCropperView({
    super.key,
    required this.image,
    this.aspectRatio,
    this.style = const CropperStyle(),
    this.decoration,
  });

  @override
  State<ImageCropperView> createState() => ImageCropperViewState();
}

class ImageCropperViewState extends State<ImageCropperView> {
  ui.Image? _image;
  Size? _imageSize;
  Rect? _imageRect; // The rect where the image is actually displayed on screen
  Rect? _cropRect; // The crop rect in VIEWPORT coordinates
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ImageCropperView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      _loadImage();
    }
    // If aspect ratio changes, we might need to reset or adjust the crop rect
    if (oldWidget.aspectRatio != widget.aspectRatio) {
      if (_imageRect != null) {
        // Resetting to center is the safest behavior when ratio changes abruptly
        _cropRect = null;
        _initializeCropRect(_imageRect!);
      }
    }
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
    });

    final ImageStream stream = widget.image.resolve(ImageConfiguration.empty);
    final Completer<ui.Image> completer = Completer<ui.Image>();

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        completer.completeError(exception, stackTrace);
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);

    try {
      _image = await completer.future;
      _imageSize = Size(_image!.width.toDouble(), _image!.height.toDouble());
      setState(() {
        _isLoading = false;
        // _cropRect will be initialized in build/layout because we need viewport size
        _imageRect = null;
      });
    } catch (e) {
      debugPrint('Error loading image: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper to calculate the fitted image rect
  Rect _calculateImageRect(Size viewportSize) {
    if (_imageSize == null) return Rect.zero;

    final double imageAspectRatio = _imageSize!.width / _imageSize!.height;
    final double viewportAspectRatio = viewportSize.width / viewportSize.height;

    double drawWidth;
    double drawHeight;

    if (imageAspectRatio > viewportAspectRatio) {
      // Image is wider than viewport
      drawWidth = viewportSize.width;
      drawHeight = viewportSize.width / imageAspectRatio;
    } else {
      // Image is taller than viewport
      drawHeight = viewportSize.height;
      drawWidth = viewportSize.height * imageAspectRatio;
    }

    final double dx = (viewportSize.width - drawWidth) / 2;
    final double dy = (viewportSize.height - drawHeight) / 2;

    return Rect.fromLTWH(dx, dy, drawWidth, drawHeight);
  }

  // Initialize crop rect to center of image, obeying aspect ratio if set
  void _initializeCropRect(Rect imageRect) {
    if (_cropRect != null) return;

    double width = imageRect.width;
    double height = imageRect.height;

    if (widget.aspectRatio != null) {
      if (width / height > widget.aspectRatio!) {
        // Image is wider than target ratio, constrain width
        width = height * widget.aspectRatio!;
      } else {
        // Image is taller, constrain height
        height = width / widget.aspectRatio!;
      }
    }

    // Default to slightly smaller than full image to show it's separate
    width *= 0.8;
    height *= 0.8;

    final double dx = imageRect.left + (imageRect.width - width) / 2;
    final double dy = imageRect.top + (imageRect.height - height) / 2;

    _cropRect = Rect.fromLTWH(dx, dy, width, height);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final Size viewportSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );

                // Calculate where the image sits
                _imageRect = _calculateImageRect(viewportSize);

                // Initialize crop rect if needed
                if (_cropRect == null && _imageRect != null) {
                  _initializeCropRect(_imageRect!);
                }

                return Stack(
                  children: [
                    // The Background Image
                    Positioned.fromRect(
                      rect: _imageRect!,
                      child: RawImage(image: _image, fit: BoxFit.fill),
                    ),
                    // The Overlay
                    if (_imageRect != null && _cropRect != null)
                      CustomPaint(
                        size: Size.infinite,
                        painter: _CropOverlayPainter(
                          imageRect: _imageRect!,
                          cropRect: _cropRect!,
                          style: widget.style,
                        ),
                      ),
                    // Interaction Layer
                    if (_imageRect != null && _cropRect != null)
                      Positioned.fill(
                        child: GestureDetector(
                          onPanStart: onPanStart,
                          onPanUpdate: onPanUpdate,
                          onPanEnd: onPanEnd,
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
  // --- Interaction Logic ---

  _HandleType? activeHandle;
  Offset? startTouchPoint;
  Rect? startCropRect;

  void onPanStart(DragStartDetails details) {
    if (_cropRect == null) return;

    final Offset pos = details.localPosition;
    activeHandle = hitTest(pos);
    startTouchPoint = pos;
    startCropRect = _cropRect;

    setState(() {});
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (activeHandle == null ||
        startTouchPoint == null ||
        startCropRect == null ||
        _imageRect == null)
      return;

    final Offset delta = details.localPosition - startTouchPoint!;
    Rect newRect = startCropRect!;

    if (activeHandle == _HandleType.move) {
      newRect = newRect.shift(delta);
    } else {
      newRect = resizeRect(newRect, activeHandle!, delta);
    }

    if (activeHandle == _HandleType.move) {
      if (newRect.left < _imageRect!.left) {
        newRect = newRect.shift(Offset(_imageRect!.left - newRect.left, 0));
      }
      if (newRect.top < _imageRect!.top) {
        newRect = newRect.shift(Offset(0, _imageRect!.top - newRect.top));
      }
      if (newRect.right > _imageRect!.right) {
        newRect = newRect.shift(Offset(_imageRect!.right - newRect.right, 0));
      }
      if (newRect.bottom > _imageRect!.bottom) {
        newRect = newRect.shift(Offset(0, _imageRect!.bottom - newRect.bottom));
      }
    } else {
      newRect = newRect.intersect(_imageRect!);
    }

    setState(() {
      _cropRect = newRect;
    });
  }

  void onPanEnd(DragEndDetails details) {
    setState(() {
      activeHandle = null;
      startTouchPoint = null;
      startCropRect = null;
    });
  }

  _HandleType? hitTest(Offset point) {
    if (_cropRect == null) return null;

    final double hitSize = widget.style.handlerSize * 1.5;

    if ((point - _cropRect!.topLeft).distance <= hitSize)
      return _HandleType.topLeft;
    if ((point - _cropRect!.topRight).distance <= hitSize)
      return _HandleType.topRight;
    if ((point - _cropRect!.bottomLeft).distance <= hitSize)
      return _HandleType.bottomLeft;
    if ((point - _cropRect!.bottomRight).distance <= hitSize)
      return _HandleType.bottomRight;

    if (_cropRect!.contains(point)) return _HandleType.move;

    return null;
  }

  Rect resizeRect(Rect original, _HandleType handle, Offset delta) {
    double left = original.left;
    double top = original.top;
    double right = original.right;
    double bottom = original.bottom;

    if (handle == _HandleType.topLeft) {
      left += delta.dx;
      top += delta.dy;
    } else if (handle == _HandleType.topRight) {
      right += delta.dx;
      top += delta.dy;
    } else if (handle == _HandleType.bottomLeft) {
      left += delta.dx;
      bottom += delta.dy;
    } else if (handle == _HandleType.bottomRight) {
      right += delta.dx;
      bottom += delta.dy;
    }

    if (widget.aspectRatio != null) {
      final double targetRatio = widget.aspectRatio!;
      final double currentWidth = right - left;

      if (handle == _HandleType.bottomRight) {
        bottom = top + (currentWidth / targetRatio);
      } else if (handle == _HandleType.bottomLeft) {
        bottom = top + (currentWidth / targetRatio);
      } else if (handle == _HandleType.topRight) {
        top = bottom - (currentWidth / targetRatio);
      } else if (handle == _HandleType.topLeft) {
        top = bottom - (currentWidth / targetRatio);
      }
    }

    if (right < left + 20) right = left + 20;
    if (bottom < top + 20) bottom = top + 20;

    return Rect.fromLTRB(left, top, right, bottom);
  }

  Rect getCropRect() {
    if (_cropRect == null || _imageRect == null || _imageSize == null)
      return Rect.zero;

    final double scaleX = _imageSize!.width / _imageRect!.width;
    final double scaleY = _imageSize!.height / _imageRect!.height;

    final double x = (_cropRect!.left - _imageRect!.left) * scaleX;
    final double y = (_cropRect!.top - _imageRect!.top) * scaleY;
    final double w = _cropRect!.width * scaleX;
    final double h = _cropRect!.height * scaleY;

    return Rect.fromLTWH(x, y, w, h);
  }

  Future<Uint8List?> getCroppedImage() async {
    if (_image == null) return null;

    final Rect cropRect = getCropRect();
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    canvas.drawImageRect(
      _image!,
      cropRect,
      Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
      Paint(),
    );

    final ui.Picture picture = recorder.endRecording();
    final ui.Image croppedImage = await picture.toImage(
      cropRect.width.toInt(),
      cropRect.height.toInt(),
    );

    final ByteData? byteData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData?.buffer.asUint8List();
  }
}

enum _HandleType { topLeft, topRight, bottomLeft, bottomRight, move }

class _CropOverlayPainter extends CustomPainter {
  final Rect imageRect;
  final Rect cropRect;
  final CropperStyle style;

  _CropOverlayPainter({
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
    // TODO: Draw fancy handles
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
  bool shouldRepaint(_CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.imageRect != imageRect;
  }
}
