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
  final ImageCropperController _controller = ImageCropperController();
  CropperRatio? _aspectRatio;
  Uint8List? _croppedImage;

  void _cropImage() async {
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
                      controller: _controller,
                      image: const NetworkImage(
                        'https://images.unsplash.com/photo-1595152772835-219674b2a8a6?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=80',
                      ),
                      aspectRatio: _aspectRatio,
                      style: const CropperStyle(
                        overlayColor: Colors.black54,
                        borderColor: Colors.white,
                        borderWidth: 1.0,
                        handlerSize: 30,
                        handlerColor: Colors.white,
                        handleType: HandleType.corner,
                        handlerThickness: 6,
                      ),
                    ),
                  ),
                ),
              ),
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
                  onPressed: () => setState(() => _aspectRatio = ratio),
                  isSelected: _aspectRatio == ratio,
                );
              }).toList(),
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
