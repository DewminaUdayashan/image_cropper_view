import 'dart:typed_data';

import 'cropper_ratio.dart';
import 'image_cropper_widget.dart';

/// A controller to manipulate the [ImageCropperWidget] state programmatically.
class ImageCropperController {
  ImageCropperWidgetState? _state;

  /// Attaches the controller to the [ImageCropperWidget] state.
  ///
  /// This is called automatically by [ImageCropperWidget] when the controller is provided.
  void attach(ImageCropperWidgetState state) {
    _state = state;
  }

  /// Detaches the controller from the [ImageCropperWidget] state.
  ///
  /// This is called when the widget is disposed.
  void detach() {
    _state = null;
  }

  /// Captures the current cropped image.
  ///
  /// * Returns: The cropped image data as a [Uint8List] formatted as PNG.
  ///   If [CropShape.oval] is used, the pixels outside the oval will be transparent.
  /// * Returns `null` if the image is not loaded or cropping fails.
  Future<Uint8List?> crop() {
    return _state?.getCroppedImage() ?? Future.value(null);
  }

  /// Sets a new [CropperRatio] for cropping.
  ///
  /// This will reset the crop rect to the new ratio, centered on the image.
  void setAspectRatio(CropperRatio ratio) {
    _state?.setAspectRatio(ratio);
  }

  /// Rotates the image by [angle] radians.
  ///
  /// This resets the crop rect to avoid out-of-bounds issues.
  void setRotation(double angle) {
    _state?.setRotation(angle);
  }

  /// Rotates the image 90 degrees to the right (clockwise).
  void rotateRight() {
    _state?.rotateRight();
  }

  /// Rotates the image 90 degrees to the left (counter-clockwise).
  void rotateLeft() {
    _state?.rotateLeft();
  }

  /// Flips the image horizontally (scales X by -1).
  ///
  /// Main crop area is preserved relative to the image bounds.
  void flipHorizontal() {
    _state?.flipHorizontal();
  }

  /// Flips the image vertically (scales Y by -1).
  void flipVertical() {
    _state?.flipVertical();
  }
}
