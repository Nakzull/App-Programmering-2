// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewScreen extends StatefulWidget {
  final CameraController cameraController;

  const CameraPreviewScreen({Key? key, required this.cameraController});

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

  //This method will first make sure the camera is initialized and then take a picture
  //And store it on the phone.
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
