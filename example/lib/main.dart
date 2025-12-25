import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper_view/image_cropper_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Cropper Demo',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Image Cropper Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 1. Initialize the controller to manage the cropper state
  final _controller = ImageCropperController();
  CropperRatio? _aspectRatio;
  Uint8List? _croppedImage;
  HandleType _handleType = HandleType.corner;

  void _cropImage() async {
    // 2. Trigger the crop action
    final Uint8List? bytes = await _controller.crop();
    if (bytes != null) {
      setState(() {
        _croppedImage = bytes;
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cropped Image'),
            content: Image.memory(bytes),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.crop), onPressed: _cropImage),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ImageCropperView(
                // 3. Configure the view
                borderRadius: BorderRadius.circular(16.0),
                controller: _controller,
                image: const AssetImage('assets/sample-image.png'),
                aspectRatio: _aspectRatio,
                // 4. Customize the look and feel
                style: CropperStyle(
                  overlayColor: Colors.black54,
                  borderColor: Colors.white,
                  handlerColor: Colors.white,
                  borderWidth: 1.0,
                  handlerSize: 30,
                  handleType: _handleType,
                  handlerThickness: 6,
                ),
                loadingWidget: const Center(child: Text('Loading...')),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                runSpacing: 6,
                spacing: 6,
                children: CropperRatio.values.map((ratio) {
                  return _AspectRatioButton(
                    label: ratio.label,
                    onPressed: () {
                      // 5. Update aspect ratio programmatically
                      _controller.setAspectRatio(ratio);
                      setState(() => _aspectRatio = ratio);
                    },
                    isSelected: _aspectRatio == ratio,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => _controller.rotateLeft(),
                  icon: const Icon(Icons.rotate_left),
                  tooltip: 'Rotate Left',
                ),
                IconButton(
                  onPressed: () => _controller.rotateRight(),
                  icon: const Icon(Icons.rotate_right),
                  tooltip: 'Rotate Right',
                ),
                IconButton(
                  onPressed: () => _controller.flipHorizontal(),
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Flip Horizontal',
                ),
                IconButton(
                  onPressed: () => _controller.flipVertical(),
                  icon: const Icon(Icons.swap_vert),
                  tooltip: 'Flip Vertical',
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  const Text('Handle Type: '),
                  const SizedBox(width: 10),
                  DropdownButton<HandleType>(
                    value: _handleType,
                    items: HandleType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _handleType = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _AspectRatioButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSelected;

  const _AspectRatioButton({
    required this.label,
    required this.onPressed,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Theme.of(context).primaryColor : null,
        foregroundColor: isSelected ? Colors.white : null,
      ),
      child: Text(label),
    );
  }
}
