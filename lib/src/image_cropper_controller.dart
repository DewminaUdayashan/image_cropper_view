import 'dart:typed_data';

import 'cropper_ratio.dart';
import 'image_cropper_view.dart';

/// A controller to manipulate the [ImageCropperView] state programmatically.
class ImageCropperController {
  ImageCropperViewState? _state;

  /// Attaches the controller to the [ImageCropperView] state.
  ///
  /// This is called automatically by [ImageCropperView] when the controller is provided.
  void attach(ImageCropperViewState state) {
    _state = state;
  }

  /// Detaches the controller from the [ImageCropperView] state.
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
