# Image Cropper Widget

A customizable, pure Dart image cropping widget for Flutter. Easily crop images with preset or custom aspect ratios, rotation, flipping, and advanced UI customization including **Grid Overlays** and **Oval/Circle Cropping**.

<img src="https://github.com/DewminaUdayashan/image_cropper_view/raw/main/doc/demo.gif" width="250" alt="Demo GIF">

## Features

- **Flexible Cropping**: Supports both free-form and preset aspect ratios.
- **Crop Shapes**: Choose between **Rectangle** or **Oval/Circle** crop areas.
- **Grid Overlay**: Built-in Rule of Thirds or custom grid divisions (3x3, 4x4, etc.).
- **Transformations**: Rotate (90° steps or custom angles) and flip (horizontal/vertical) images.
- **Customizable UI**: Fully style the overlay, borders, drag handles (corner/circle), and colors.
- **High Performance**: Built with standard Flutter widgets and custom painters for smooth interaction.
- **No Native Dependencies**: Pure Dart implementation, ensuring compatibility across all platforms.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  image_cropper_widget: ^1.0.6
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
        Expanded(
          child: ImageCropperWidget(
            image: AssetImage('assets/my_image.png'),
            controller: _controller,
            aspectRatio: CropperRatio.ratio4_3, // Optional: Force 4:3
            style: CropperStyle(
               corner,
              cropShape: CropShape.oval, // Enable Oval cropping
              showGrid: true,
              gridDivisions: 3, // Rule of Thirds
            ),
          ),
        ),
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

Customize the look and feel using `CropperStyle`. The `image_cropper_view` allows you to customize almost every visual aspect:

```dart
ImageCropperWidget(
  image: ...,
  style: CropperStyle(
    // Overlay
    overlayColor: Colors.black.withOpacity(0.7),
    overlayPadding: 20.0, // Gap between image and border
    
    // Border
    borderColor: Colors.blueAccent,
    borderWidth: 2.0,
    cropBorderRadius: 12.0, // Rounded corners for rectangle
    
    // Handles
    handlerColor: Colors.blue,
    handlerSize: 14.0,
    handleType: HandleType.corner, // .circle or .corner
    
    // Grid
    showGrid: true,
    gridLineColor: Colors.white54,
    gridDivisions: 3, // 3x3 Grid
    
    // Shape
    cropShape: CropShape.rectangle, // .rectangle or .oval
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
| `cropBorderRadius` | `double` | `0.0` | Radius for rounded crop corners (Rectangle only). |
| `overlayPadding` | `double` | `2.0` | Visual gap between the image boundary and the crop border. |
| `enableFeedback` | `bool` | `true` | Whether to provide haptic feedback. |
| `enableScaleAnimation`| `bool` | `true` | Whether handles animate scale on touch. |
| `showGrid` | `bool` | `true` | Whether to show the grid overlay. |
| `gridLineColor` | `Color` | `white54` | Color of the grid lines. |
| `gridLineWidth` | `double` | `1.0` | Width of the grid lines. |
| `gridDivisions` | `int` | `3` | Number of divisions in the grid (e.g., 3 for 3x3). |
| `cropShape` | `CropShape` | `.rectangle` | Shape of the crop area (`.rectangle` or `.oval`). |

## License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.
