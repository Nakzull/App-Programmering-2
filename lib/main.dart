import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'takePicture.dart';
import 'board.dart';
import 'http.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

//Register singleton instances of UserRepository and ApiService using setupLocator.
void setupLocator() {
  locator.registerSingleton<UserRepository>(DataRepository.getInstance());
  locator
      .registerSingleton<ApiService>(ApiService('http://10.0.2.2:7258/home'));
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  _MainMenuScreenState createState() {
    return _MainMenuScreenState();
  }
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late CameraController _cameraController;
  List<CameraDescription> cameras = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    //Delayed execution to simulate loading for 5 seconds.
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Widget buildCameraPreview(BuildContext context) {
    return CameraPreviewScreen(cameraController: _cameraController);
  }

  Widget buildBoard(BuildContext context) {
    return const Board();
  }

  Widget buildHttp(BuildContext context) {
    return Http(
      userRepository: locator<UserRepository>(),
    );
  }

  //This retrieves available cameras and initialize the first one.
  void _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController =
          CameraController(cameras.first, ResolutionPreset.medium);
      await _cameraController.initialize();
    }
  }

  //This disposes of the camera controller.
  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  //Check if the menu is enabled based on the loading state.
  bool isMenuEnabled() {
    return !isLoading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [],
            ),
      drawer: isMenuEnabled()
          ? Drawer(
              child: ListView(
                children: [
                  //This menu item calls the initializeCamera to ensure the camera
                  //is available when swapping to the CameraPreview.
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
                      Navigator.push(
                          context, MaterialPageRoute(builder: buildBoard));
                    },
                  ),
                  ListTile(
                    title: const Text('Hello World'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context, MaterialPageRoute(builder: buildHttp));
                    },
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

void main() {
  //Initialize the dependency locator.
  setupLocator();
  runApp(const MaterialApp(
    home: MainMenuScreen(),
  ));
}
