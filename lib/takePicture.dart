import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewScreen extends StatefulWidget {
  final CameraController cameraController;

  const CameraPreviewScreen({super.key, required this.cameraController});

  @override
  _CameraPreviewScreenState createState() {
    return _CameraPreviewScreenState();
  }
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Preview'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CameraPreview(widget.cameraController),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _takePicture(context);
            },
            child: const Text('Take Picture'),
          ),
        ],
      ),
    );
  }

  void _takePicture(BuildContext context) async {
    if (!widget.cameraController.value.isInitialized) {
      await widget.cameraController.initialize();
    }

    try {
      final XFile picture = await widget.cameraController.takePicture();
      await widget.cameraController.dispose();
      Navigator.pop(context, picture);
    } catch (e) {
      if (kDebugMode) {
        print('Error taking picture: $e');
      }
    }
  }
}
