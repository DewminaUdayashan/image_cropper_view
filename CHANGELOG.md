## 1.0.0

* Initial release of the package.

## 1.0.1

* Updated README.md

## 1.0.2

* Update README.md

## 1.0.3

* Pass static analysis

## 1.0.4

* **New Feature**: Added `overlayPadding` to `CropperStyle` to allow a configurable visual gap between the image and crop border.
* **Improvement**: Handles can now extend outside the image boundaries into the padded area, preventing them from obscuring the image content.
* **Improvement**: Added automatic safe area calculation to prevent handles from being clipped by the widget boundary.
* **Visual Polish**: Restricted the dimmed overlay to only cover the image, leaving the padding area transparent.
* **Bug Fix**: Fixed crop handle visibility issues when resizing to image edge.
* **Bug Fix**: Fixed aspect ratio selection not immediately updating the crop area.
