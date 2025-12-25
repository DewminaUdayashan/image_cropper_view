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
  void detach() {
    _state = null;
  }

  /// Captures the current cropped image.
  ///
  /// Returns the cropped image data as a [Uint8List] formatted as PNG,
  /// or `null` if the image is not loaded or cropping fails.
  Future<Uint8List?> crop() {
    return _state?.getCroppedImage() ?? Future.value(null);
  }

  /// Sets a new aspect ratio for cropping.
  void setAspectRatio(CropperRatio ratio) {
    _state?.setAspectRatio(ratio);
  }

  /// Rotates the image by [angle] radians.
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
  void flipHorizontal() {
    _state?.flipHorizontal();
  }

  /// Flips the image vertically (scales Y by -1).
  void flipVertical() {
    _state?.flipVertical();
  }
}
