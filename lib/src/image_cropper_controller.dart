import 'dart:typed_data';

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
}
