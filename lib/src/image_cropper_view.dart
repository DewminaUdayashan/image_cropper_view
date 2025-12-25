import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'crop_overlay_painter.dart';
import 'cropper_ratio.dart';
import 'cropper_style.dart';
import 'image_cropper_controller.dart';

class ImageCropperView extends StatefulWidget {
  final ImageProvider image;
  final CropperRatio? aspectRatio;
  final CropperStyle style;
  final BorderRadiusGeometry borderRadius;
  final ImageCropperController? controller;

  const ImageCropperView({
    super.key,
    required this.image,
    this.aspectRatio,
    this.style = const CropperStyle(),
    this.borderRadius = BorderRadius.zero,
    this.controller,
  });

  @override
  State<ImageCropperView> createState() => ImageCropperViewState();
}

class ImageCropperViewState extends State<ImageCropperView>
    with SingleTickerProviderStateMixin {
  ui.Image? _image;
  Size? _imageSize;
  Rect? _imageRect; // The rect where the image is actually displayed on screen

  late final ValueNotifier<Rect?> _cropRectNotifier;
  late final ValueNotifier<CropHandleSide?> _activeHandleNotifier;

  bool _isLoading = true;
  late AnimationController _scaleController;
  CropperRatio? _currentAspectRatio;

  // Transform State
  double _rotation = 0.0; // Radians
  bool _flipX = false;
  bool _flipY = false;

  @override
  void initState() {
    super.initState();
    _cropRectNotifier = ValueNotifier(null);
    _activeHandleNotifier = ValueNotifier(null);

    _currentAspectRatio = widget.aspectRatio;
    _scaleController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
          lowerBound: 1.0,
          upperBound: widget.style.activeHandlerScale,
        )..addListener(() {
          // No setState needed for scale animation as we pass the controller directly
        });

    widget.controller?.attach(this);
    _loadImage();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _cropRectNotifier.dispose();
    _activeHandleNotifier.dispose();
    widget.controller?.detach();
    super.dispose();
  }

  @override
  void didUpdateWidget(ImageCropperView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.detach();
      widget.controller?.attach(this);
    }
    if (oldWidget.image != widget.image) {
      _loadImage();
    }

    // If aspect ratio changes via WIDGET param, update internal state
    if (oldWidget.aspectRatio != widget.aspectRatio) {
      _currentAspectRatio = widget.aspectRatio;
      if (_imageRect != null) {
        // Resetting to center is the safest behavior when ratio changes abruptly
        _cropRectNotifier.value = null;
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

    // Calculate effective image size based on rotation
    final double rads = _rotation;
    // Basic bounding box rotation:
    // newW = w*|cos| + h*|sin|
    // newH = w*|sin| + h*|cos|
    final double cosVal = (math.cos(rads)).abs();
    final double sinVal = (math.sin(rads)).abs();

    final double width = _imageSize!.width;
    final double height = _imageSize!.height;

    final double rotatedWidth = width * cosVal + height * sinVal;
    final double rotatedHeight = width * sinVal + height * cosVal;

    final double imageAspectRatio = rotatedWidth / rotatedHeight;
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
    if (_cropRectNotifier.value != null) return;

    double width = imageRect.width;
    double height = imageRect.height;

    final double? targetRatio = _currentAspectRatio?.ratio;

    if (targetRatio != null) {
      if (width / height > targetRatio) {
        // Image is wider than target ratio, constrain width
        width = height * targetRatio;
      } else {
        // Image is taller, constrain height
        height = width / targetRatio;
      }
    }

    // Default to slightly smaller than full image to show it's separate
    width *= 0.8;
    height *= 0.8;

    final double dx = imageRect.left + (imageRect.width - width) / 2;
    final double dy = imageRect.top + (imageRect.height - height) / 2;

    _cropRectNotifier.value = Rect.fromLTWH(dx, dy, width, height);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                Size viewportSize;
                if (!constraints.hasBoundedHeight) {
                  // Adaptive height: calculate based on image aspect ratio
                  if (_imageSize != null) {
                    final double rads = _rotation;
                    final double cosVal = (math.cos(rads)).abs();
                    final double sinVal = (math.sin(rads)).abs();
                    final double width = _imageSize!.width;
                    final double height = _imageSize!.height;

                    final double rotatedWidth =
                        width * cosVal + height * sinVal;
                    final double rotatedHeight =
                        width * sinVal + height * cosVal;

                    final double aspectRatio = rotatedHeight == 0
                        ? 1.0
                        : rotatedWidth / rotatedHeight;
                    double desiredHeight = constraints.maxWidth / aspectRatio;

                    if (desiredHeight.isInfinite || desiredHeight.isNaN) {
                      desiredHeight = constraints.maxWidth;
                    }
                    viewportSize = Size(constraints.maxWidth, desiredHeight);
                  } else {
                    viewportSize = Size(
                      constraints.maxWidth,
                      constraints.maxWidth,
                    );
                  }
                } else {
                  viewportSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                }

                // Ensure finite height
                if (viewportSize.height.isInfinite ||
                    viewportSize.height.isNaN) {
                  viewportSize = Size(viewportSize.width, 300);
                }

                // Calculate where the image sits
                _imageRect = _calculateImageRect(viewportSize);

                // Initialize crop rect if needed
                if (_cropRectNotifier.value == null && _imageRect != null) {
                  _initializeCropRect(_imageRect!);
                }

                return SizedBox(
                  width: viewportSize.width,
                  height: viewportSize.height,
                  child: Stack(
                    children: [
                      // The Background Image
                      Positioned.fromRect(
                        rect: _imageRect!,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateZ(_rotation)
                            ..scale(
                              _flipX ? -1.0 : 1.0,
                              _flipY ? -1.0 : 1.0,
                              1.0,
                            ),
                          child: RawImage(image: _image, fit: BoxFit.fill),
                        ),
                      ),
                      // The Overlay
                      if (_imageRect != null)
                        ValueListenableBuilder<Rect?>(
                          valueListenable: _cropRectNotifier,
                          builder: (context, cropRect, child) {
                            if (cropRect == null)
                              return const SizedBox.shrink();
                            return CustomPaint(
                              size: Size.infinite,
                              painter: CropOverlayPainter(
                                imageRect: _imageRect!,
                                cropRect: _cropRectNotifier,
                                style: widget.style,
                                activeHandle: _activeHandleNotifier,
                                scale: _scaleController,
                              ),
                            );
                          },
                        ),
                      // Interaction Layer
                      if (_imageRect != null)
                        Positioned.fill(
                          child: GestureDetector(
                            onPanStart: onPanStart,
                            onPanUpdate: onPanUpdate,
                            onPanEnd: onPanEnd,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
  // --- Interaction Logic ---

  Offset? startTouchPoint;
  Rect? startCropRect;

  void onPanStart(DragStartDetails details) {
    if (_cropRectNotifier.value == null) return;

    final Offset pos = details.localPosition;
    _activeHandleNotifier.value = hitTest(pos);
    startTouchPoint = pos;
    startCropRect = _cropRectNotifier.value;

    if (_activeHandleNotifier.value != null) {
      if (widget.style.enableFeedback) {
        HapticFeedback.lightImpact();
      }
      if (widget.style.enableScaleAnimation) {
        _scaleController.forward();
      }
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (_activeHandleNotifier.value == null ||
        startTouchPoint == null ||
        startCropRect == null ||
        _imageRect == null) {
      return;
    }
    final Offset delta = details.localPosition - startTouchPoint!;
    Rect newRect = startCropRect!;
    final CropHandleSide handle = _activeHandleNotifier.value!;

    if (handle == CropHandleSide.move) {
      newRect = newRect.shift(delta);
    } else {
      newRect = resizeRect(newRect, handle, delta, _imageRect!);
    }

    if (handle == CropHandleSide.move) {
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
    }

    _cropRectNotifier.value = newRect;
  }

  void onPanEnd(DragEndDetails details) {
    if (widget.style.enableScaleAnimation) {
      _scaleController.reverse();
    }
    _activeHandleNotifier.value = null;
    startTouchPoint = null;
    startCropRect = null;
  }

  CropHandleSide? hitTest(Offset point) {
    if (_cropRectNotifier.value == null) return null;
    final Rect cropRect = _cropRectNotifier.value!;

    final double hitSize = widget.style.handlerSize * 1.5;

    if ((point - cropRect.topLeft).distance <= hitSize) {
      return CropHandleSide.topLeft;
    }
    if ((point - cropRect.topRight).distance <= hitSize) {
      return CropHandleSide.topRight;
    }
    if ((point - cropRect.bottomLeft).distance <= hitSize) {
      return CropHandleSide.bottomLeft;
    }
    if ((point - cropRect.bottomRight).distance <= hitSize) {
      return CropHandleSide.bottomRight;
    }

    if (cropRect.contains(point)) return CropHandleSide.move;

    return null;
  }

  Rect resizeRect(
    Rect original,
    CropHandleSide handle,
    Offset delta,
    Rect bounds,
  ) {
    double left = original.left;
    double top = original.top;
    double right = original.right;
    double bottom = original.bottom;

    // Apply delta based on handle
    if (handle == CropHandleSide.topLeft) {
      left += delta.dx;
      top += delta.dy;
    } else if (handle == CropHandleSide.topRight) {
      right += delta.dx;
      top += delta.dy;
    } else if (handle == CropHandleSide.bottomLeft) {
      left += delta.dx;
      bottom += delta.dy;
    } else if (handle == CropHandleSide.bottomRight) {
      right += delta.dx;
      bottom += delta.dy;
    }

    // Min size check (pre-aspect ratio to avoid collapse)
    if (right < left + 20) {
      if (handle == CropHandleSide.topLeft ||
          handle == CropHandleSide.bottomLeft) {
        left = right - 20;
      } else {
        right = left + 20;
      }
    }
    if (bottom < top + 20) {
      if (handle == CropHandleSide.topLeft ||
          handle == CropHandleSide.topRight) {
        top = bottom - 20;
      } else {
        bottom = top + 20;
      }
    }

    final double? targetRatio = _currentAspectRatio?.ratio;

    if (targetRatio != null) {
      // 1. Enforce Aspect Ratio
      final double currentWidth = right - left;

      // We prioritize width for TopRight/BottomRight/TopLeft/BottomLeft consistency
      // But we must respect which handle is driving which dimension.
      // Simplified: Calculate height from width.

      if (handle == CropHandleSide.bottomRight) {
        bottom = top + (currentWidth / targetRatio);
      } else if (handle == CropHandleSide.bottomLeft) {
        bottom = top + (currentWidth / targetRatio);
      } else if (handle == CropHandleSide.topRight) {
        top = bottom - (currentWidth / targetRatio);
      } else if (handle == CropHandleSide.topLeft) {
        top = bottom - (currentWidth / targetRatio);
      }

      // 2. Check Bounds & Re-adjust
      // If we went out of bounds, clip the violating edge, then re-calculate the other dimension.

      if (left < bounds.left) {
        left = bounds.left;
        // Re-calculate dependent dimension
        double w = right - left;
        if (handle == CropHandleSide.topLeft ||
            handle == CropHandleSide.bottomLeft) {
          // We moved left, so we change width.
          // If we are TopLeft, Top depends on Width.
          if (handle == CropHandleSide.topLeft) {
            top = bottom - (w / targetRatio);
          }
          if (handle == CropHandleSide.bottomLeft) {
            bottom = top + (w / targetRatio);
          }
        }
      }
      if (top < bounds.top) {
        top = bounds.top;
        double h = bottom - top;
        if (handle == CropHandleSide.topLeft ||
            handle == CropHandleSide.topRight) {
          // We moved top. Width depends on Height?
          // Current logic drove Height from Width. Now Height determines Width.
          // w = h * ratio
          double w = h * targetRatio;
          if (handle == CropHandleSide.topLeft) left = right - w;
          if (handle == CropHandleSide.topRight) right = left + w;
        }
      }
      if (right > bounds.right) {
        right = bounds.right;
        double w = right - left;
        if (handle == CropHandleSide.topRight ||
            handle == CropHandleSide.bottomRight) {
          if (handle == CropHandleSide.topRight) {
            top = bottom - (w / targetRatio);
          }
          if (handle == CropHandleSide.bottomRight) {
            bottom = top + (w / targetRatio);
          }
        }
      }
      if (bottom > bounds.bottom) {
        bottom = bounds.bottom;
        double h = bottom - top;
        if (handle == CropHandleSide.bottomLeft ||
            handle == CropHandleSide.bottomRight) {
          double w = h * targetRatio;
          if (handle == CropHandleSide.bottomLeft) left = right - w;
          if (handle == CropHandleSide.bottomRight) right = left + w;
        }
      }

      // 3. Double Check (Corner case: correcting one side might push the other out)
      // If still out of bounds, we simply clamp to the intersection safe area
      // (This technically changes the ratio, but only when the image is physically too small
      // to fit the aspect ratio in that corner, which is rare if we started valid).
      // However, better behavior might be to shrink the entire rect to fit.
      // For now, let's just ensure we don't return invalid rects.
    }

    // Final strict clamp to ensure no crash, though logic above should handle it.
    // If we are strictly maintaining aspect ratio, simple clamping breaks it.
    // But if we are "stuck" in a corner, we might have to.
    // Let's trust logic above for AR, and only clamp if free-form.

    if (targetRatio == null) {
      if (left < bounds.left) left = bounds.left;
      if (top < bounds.top) top = bounds.top;
      if (right > bounds.right) right = bounds.right;
      if (bottom > bounds.bottom) bottom = bounds.bottom;
    }

    // Min size check again
    if (right < left + 20) right = left + 20;
    if (bottom < top + 20) bottom = top + 20;

    return Rect.fromLTRB(left, top, right, bottom);
  }

  void setAspectRatio(CropperRatio ratio) {
    if (_currentAspectRatio != ratio) {
      // Logic update: We don't need full setState if only ratio changes,
      // but re-initializing crop rect DOES require updating the notifier.
      // However, modifying _currentAspectRatio might be used elsewhere.
      setState(() {
        _currentAspectRatio = ratio;
        if (_imageRect != null) {
          _cropRectNotifier.value = null; // Reset to force re-init
          _initializeCropRect(_imageRect!);
        }
      });
    }
  }

  void setRotation(double angle) {
    setState(() {
      _rotation = angle;
      if (_imageRect != null) {
        _cropRectNotifier.value =
            null; // Reset crop on rotation change to avoid OOB
        // Re-layout will happen on build
      }
    });
  }

  void rotateRight() {
    setState(() {
      _rotation += math.pi / 2;
      _cropRectNotifier.value = null;
    });
  }

  void rotateLeft() {
    setState(() {
      _rotation -= math.pi / 2;
      _cropRectNotifier.value = null;
    });
  }

  void flipHorizontal() {
    setState(() {
      _flipX = !_flipX;
      // Flip doesn't change bounds size, so crop rect technically fits,
      // but the *content* changes. Usually fine to keep crop rect.
    });
  }

  void flipVertical() {
    setState(() {
      _flipY = !_flipY;
    });
  }

  Future<Uint8List?> getCroppedImage() async {
    if (_image == null ||
        _cropRectNotifier.value == null ||
        _imageRect == null) {
      return null;
    }

    final Rect cropRect = _cropRectNotifier.value!;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // cropRect is in Viewport coordinates.
    // _imageRect is the Viewport rect of the TRANSFORMED image.
    // We need to verify what we are cropping.
    //
    // The visual result on screen is:
    // 1. Image is rendered at native size.
    // 2. Transformed (Rotated/Flipped).
    // 3. Scaled down to fit _imageRect.
    //
    // When capturing:
    // We want an image of size `cropRect.width * scale` x `cropRect.height * scale`?
    // Or just the cropRect size?
    // Typically we want the high-res result.
    //
    // Scale factor: Native Image (rotated/flipped bounds) / _imageRect (viewport).
    //
    // Let's re-calculate the "Rotated/Flipped Native Size".
    final double rads = _rotation;
    final double cosVal = (math.cos(rads)).abs();
    final double sinVal = (math.sin(rads)).abs();
    final double width = _image!.width.toDouble();
    final double height = _image!.height.toDouble();
    final double rotatedNativeWidth = width * cosVal + height * sinVal;
    final double rotatedNativeHeight = width * sinVal + height * cosVal;

    final double scaleX = rotatedNativeWidth / _imageRect!.width;
    final double scaleY = rotatedNativeHeight / _imageRect!.height;

    // The crop rect in "Rotated Native Space"
    final Rect nativeCropRect = Rect.fromLTWH(
      (cropRect.left - _imageRect!.left) * scaleX,
      (cropRect.top - _imageRect!.top) * scaleY,
      cropRect.width * scaleX,
      cropRect.height * scaleY,
    );

    // Target Canvas Size
    final int targetWidth = nativeCropRect.width.toInt();
    final int targetHeight = nativeCropRect.height.toInt();

    // 1. Move the origin to the top-left of the crop area (effectively cropping)
    canvas.translate(-nativeCropRect.left, -nativeCropRect.top);

    // 2. We need to draw the original image such that it ends up
    // rotated/flipped and aligned with `nativeCropRect` space.
    //
    // The "Rotated Native Space" origin (0,0) is the top-left of the bounding box
    // of the rotated image.
    // The original image needs to be positioned within this bounding box.
    //
    // Center of Rotated Native Space:
    final Offset center = Offset(
      rotatedNativeWidth / 2,
      rotatedNativeHeight / 2,
    );

    canvas.translate(center.dx, center.dy);
    canvas.rotate(_rotation);
    canvas.scale(_flipX ? -1.0 : 1.0, _flipY ? -1.0 : 1.0);

    // After transform, we are at the center of the image.
    // Draw image centered there.
    canvas.drawImage(
      _image!,
      Offset(-width / 2, -height / 2),
      Paint()..filterQuality = FilterQuality.high,
    );

    final ui.Picture picture = recorder.endRecording();
    final ui.Image croppedImage = await picture.toImage(
      targetWidth,
      targetHeight,
    );

    final ByteData? byteData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData?.buffer.asUint8List();
  }
}
