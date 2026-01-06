## 1.0.6

* **New Feature**: Added support for Oval/Circle cropping via `CropShape.oval` in `CropperStyle`.
* **New Feature**: Added `cropShape` to `CropperStyle` to toggle between Rectangle and Oval.
* **Documentation**: Comprehensive documentation updates for `ImageCropperWidget`, `CropperStyle`, and `ImageCropperController`.
* **Improvement**: Enhanced `getCroppedImage` to produce transparent corners when using oval crop.

## 1.0.5

* **New Feature**: Added Grid Overlay support (Rule of Thirds) to assist with framing.
* **New Feature**: Added `showGrid` to `CropperStyle` to toggle the grid visibility.
* **New Feature**: Added `gridDivisions` to `CropperStyle` to customize the grid density (e.g., 3x3, 4x4).
* **New Feature**: Added `gridLineColor` and `gridLineWidth` for custom grid styling.

## 1.0.4

* **New Feature**: Added `overlayPadding` to `CropperStyle` to allow a configurable visual gap between the image and crop border.
* **Improvement**: Handles can now extend outside the image boundaries into the padded area, preventing them from obscuring the image content.
* **Improvement**: Added automatic safe area calculation to prevent handles from being clipped by the widget boundary.
* **Visual Polish**: Restricted the dimmed overlay to only cover the image, leaving the padding area transparent.
* **Bug Fix**: Fixed crop handle visibility issues when resizing to image edge.
* **Bug Fix**: Fixed aspect ratio selection not immediately updating the crop area.

## 1.0.3

* Pass static analysis

## 1.0.2

* Update README.md

## 1.0.1

* Updated README.md

## 1.0.0

* Initial release of the package.

