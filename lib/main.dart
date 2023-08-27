import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'takePicture.dart';
import 'board.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() {
    return _MainMenuScreenState();
  }
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late CameraController _cameraController;
  List<CameraDescription> cameras = [];

  Widget buildCameraPreview(BuildContext context) {
    return CameraPreviewScreen(cameraController: _cameraController);
  }

  Widget buildBoard(BuildContext context) {
    return const Board();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController =
          CameraController(cameras.first, ResolutionPreset.medium);
      await _cameraController.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Take a picture'),
              onTap: () async {
                _initializeCamera();
                await Future.delayed(const Duration(seconds: 1));
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: buildCameraPreview),
                );
              },
            ),
            ListTile(
              title: const Text('Show board'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: buildBoard));
              },
            )
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MainMenuScreen(),
  ));
}
