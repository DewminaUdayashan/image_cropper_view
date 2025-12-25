import 'dart:typed_data';

import 'cropper_ratio.dart';
import 'image_cropper_view.dart';

class ImageCropperController {
  ImageCropperViewState? _state;

  void attach(ImageCropperViewState state) {
    _state = state;
  }

  void detach() {
    _state = null;
  }

  Future<Uint8List?> crop() {
    return _state?.getCroppedImage() ?? Future.value(null);
  }

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
