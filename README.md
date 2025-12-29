# Image Cropper Widget

A customizable, pure Dart image cropping widget for Flutter. Easily crop images with preset or custom aspect ratios, rotation, flipping, and advanced UI customization.

<img src="https://github.com/DewminaUdayashan/image_cropper_view/raw/main/doc/demo.gif" width="250" alt="Demo GIF">

## Features

- **Flexible Cropping**: Supports both free-form and preset aspect ratios.
- **Transformations**: Rotate (90° steps or custom angles) and flip (horizontal/vertical) images.
- **Customizable UI**: Fully style the overlay, borders, and crop handles to match your app's design.
- **High Performance**: Built with standard Flutter widgets and custom painters for smooth interaction.
- **No Native Dependencies**: Pure Dart implementation, ensuring compatibility across all platforms.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  image_cropper_widget: ^1.0.2
```

## Getting Started

 Import the package:

```dart
import 'package:image_cropper_widget/image_cropper_widget.dart';
```

Wrap your image with `ImageCropperWidget` and provide a controller:

```dart
class MyCropScreen extends StatefulWidget {
  @override
  _MyCropScreenState createState() => _MyCropScreenState();
}

class _MyCropScreenState extends State<MyCropScreen> {
  final _controller = ImageCropperController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImageCropperWidget(
            image: AssetImage('assets/my_image.png'),
            controller: _controller,
            aspectRatio: CropperRatio.ratio4_3, // Optional: Force 4:3
        )
        ElevatedButton(
          onPressed: () async {
            final Uint8List? croppedBytes = await _controller.crop();
            if (croppedBytes != null) {
              // Use the cropped image...
            }
          },
          child: Text('Crop Image'),
        ),
      ],
    );
  }
}
```

## Advanced Usage

### ImageCropperController

Use the controller to manipulate the view programmatically:

```dart
// Rotate
_controller.rotateLeft();
_controller.rotateRight();
_controller.setRotation(math.pi / 4); // 45 degrees

// Flip
_controller.flipHorizontal();
_controller.flipVertical();

// Change Aspect Ratio
_controller.setAspectRatio(CropperRatio.ratio16_9);
_controller.setAspectRatio(CropperRatio.custom); // Free-form
```

### CropperStyle

Customize the look and feel using `CropperStyle`:

```dart
ImageCropperWidget(
  image: ...,
  style: CropperStyle(
    overlayColor: Colors.black.withOpacity(0.7),
    borderColor: Colors.blueAccent,
    borderWidth: 2.0,
    handlerColor: Colors.blue,
    handlerSize: 14.0,
    handleType: HandleType.corner, // .circle or .corner
    handlerThickness: 4.0, // Only for corner handles
    cropBorderRadius: 0.0, // Sharp corners
  ),
)
```

## API Reference

### ImageCropperWidget

| Parameter | Type | Description |
|---|---|---|
| `image` | `ImageProvider` | **Required**. The image to display (AssetImage, NetworkImage, FileImage, etc.). |
| `controller` | `ImageCropperController?` | Controller to interact with the cropper state. |
| `aspectRatio` | `CropperRatio?` | Initial aspect ratio (default: null/custom). |
| `style` | `CropperStyle` | Visual configuration for the overlay. |
| `borderRadius` | `BorderRadiusGeometry` | Border radius for the widget itself. |
| `fit` | `BoxFit` | How the image fits into the available space (default: BoxFit.contain). |

### CropperRatio

Available presets:
- `CropperRatio.original`
- `CropperRatio.ratio1_1` (Square)
- `CropperRatio.ratio3_4`
- `CropperRatio.ratio4_3`
- `CropperRatio.ratio16_9`
- `CropperRatio.ratio9_16`
- `CropperRatio.custom` (Free-form)

### CropperStyle

| Parameter | Type | Default | Description |
|---|---|---|---|
| `overlayColor` | `Color` | `black54` | The color of the overlay mask outside the crop area. |
| `borderColor` | `Color` | `Colors.white` | The color of the crop border. |
| `borderWidth` | `double` | `2.0` | The width of the crop border. |
| `handlerColor` | `Color` | `Colors.white` | The color of the crop handles. |
| `handlerSize` | `double` | `12.0` | The size of the crop handles. |
| `handleType` | `HandleType` | `.circle` | Shape of handles (`.circle` or `.corner`). |
| `handlerThickness` | `double` | `2.0` | Thickness of lines for corner handles. |
| `cropBorderRadius` | `double` | `0.0` | Radius for rounded crop corners. |
| `overlayPadding` | `double` | `0.0` | Visual gap between the image boundary and the crop border. |
| `enableFeedback` | `bool` | `true` | Whether to provide haptic feedback. |
| `enableScaleAnimation`| `bool` | `true` | Whether handles animate scale on touch. |

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.
