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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  final GlobalKey<ImageCropperViewState> _cropperKey =
      GlobalKey<ImageCropperViewState>();
  double? _aspectRatio;
  Uint8List? _croppedImage;

  void _cropImage() async {
    final Uint8List? bytes = await _cropperKey.currentState?.getCroppedImage();
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height / 2,
                    child: ImageCropperView(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      key: _cropperKey,
                      image: const NetworkImage(
                        'https://images.unsplash.com/photo-1595152772835-219674b2a8a6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=80',
                      ),
                      aspectRatio: _aspectRatio,
                      style: const CropperStyle(
                        overlayColor: Colors.black54,
                        borderColor: Colors.orange,
                        handlerColor: Colors.orange,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AspectRatioButton(
                  label: 'Free',
                  onPressed: () => setState(() => _aspectRatio = null),
                  isSelected: _aspectRatio == null,
                ),
                _AspectRatioButton(
                  label: '1:1',
                  onPressed: () => setState(() => _aspectRatio = 1.0),
                  isSelected: _aspectRatio == 1.0,
                ),
                _AspectRatioButton(
                  label: '4:3',
                  onPressed: () => setState(() => _aspectRatio = 4 / 3),
                  isSelected: _aspectRatio == 4 / 3,
                ),
                _AspectRatioButton(
                  label: '16:9',
                  onPressed: () => setState(() => _aspectRatio = 16 / 9),
                  isSelected: _aspectRatio == 16 / 9,
                ),
                _AspectRatioButton(
                  label: '9:16',
                  onPressed: () => setState(() => _aspectRatio = 9 / 16),
                  isSelected: _aspectRatio == 9 / 16,
                ),
                _AspectRatioButton(
                  label: '3:4',
                  onPressed: () => setState(() => _aspectRatio = 3 / 4),
                  isSelected: _aspectRatio == 3 / 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
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
