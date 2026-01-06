import 'package:flutter/material.dart';

/// Specifies the shape of the crop handles.
enum HandleType {
  /// Circular handles.
  circle,

  /// Corner-bracket style handles.
  corner,
}

/// Defines the visual usage style and configuration for the [ImageCropperView].
class CropperStyle {
  /// The color of the overlay mask outside the crop area.
  ///
  /// Defaults to a semi-transparent black.
  final Color overlayColor;

  /// The color of the border around the crop area.
  final Color borderColor;

  /// The width of the border around the crop area.
  final double borderWidth;

  /// The color of the crop handles.
  final Color handlerColor;

  /// The size (diameter or length) of the crop handles.
  final double handlerSize;

  /// The type of handles to display (circle or corner).
  final HandleType handleType;

  /// The thickness of the crop handles (only applicable for [HandleType.corner]).
  final double handlerThickness;

  /// The border radius of the crop area itself.
  ///
  /// This creates a rounded crop rectangle.
  final double cropBorderRadius;

  /// Whether to provide haptic feedback during interaction.
  final bool enableFeedback;

  /// Whether to animate scale on interaction (zoom-in effect on handles).
  final bool enableScaleAnimation;

  /// The scale factor for the active handle during interaction.
  final double activeHandlerScale;

  /// Padding around the crop overlay (gap between image and border).
  final double overlayPadding;

  /// Whether to show a grid overlay (Rule of Thirds when [gridDivisions] is 3).
  final bool showGrid;

  /// The color of the grid lines.
  final Color gridLineColor;

  /// The width of the grid lines.
  final double gridLineWidth;

  /// The number of divisions in the grid (e.g., 3 for a 3x3 grid).
  /// Must be at least 2.
  final int gridDivisions;

  /// Creates a [CropperStyle] with customizable visual properties.
  const CropperStyle({
    this.overlayColor = const Color.fromARGB(150, 0, 0, 0),
    this.borderColor = Colors.amberAccent,
    this.borderWidth = 2.0,
    this.handlerColor = Colors.amber,
    this.handlerSize = 20.0,
    this.handleType = HandleType.circle,
    this.handlerThickness = 4.0,
    this.cropBorderRadius = 12.0,
    this.enableFeedback = true,
    this.enableScaleAnimation = true,
    this.activeHandlerScale = 1.3,
    this.overlayPadding = 2.0,
    this.showGrid = true,
    this.gridLineColor = const Color(0x8AFFFFFF), // Colors.white54
    this.gridLineWidth = 1.0,
    this.gridDivisions = 3,
  }) : assert(gridDivisions >= 2, 'gridDivisions must be at least 2');
}
