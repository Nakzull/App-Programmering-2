import 'package:app5/http.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);

  @override
  State<Board> createState() {
    return _BoardState();
  }
}

//A factory function to build the Board widget.
Widget buildBoard(BuildContext context) {
  return const Board();
}

class _BoardState extends State<Board> {
  final UserRepository userRepository = locator<UserRepository>();
  final List<Matrix4> _imageMatrices = [];
  final List<File> _selectedImages = [];
  final double _imageScaleFactor = 0.5;

  //Function to pick an image from the gallery.
  Future<void> _pickImageFromGallery() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    //Check if an image is picked and then uploads it to the server.
    if (pickedImage != null) {
      final imageFile = File(pickedImage.path);

      userRepository.uploadPicture(imageFile, 'UploadPicture');

      //Downloads the newest added image from the server.
      final imageUrl = await userRepository.downloadNewestPicture('DownloadPicture');
      setState(() {
        _selectedImages.add(imageUrl);
        _imageMatrices.add(Matrix4.diagonal3Values(_imageScaleFactor, _imageScaleFactor, 1.0));
      });
    }
  }

  //Function to remove all images from the board.
  void _removeAllImages() {
    setState(() {
      _selectedImages.clear();
      _imageMatrices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Board'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: const Text('Add Picture'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _removeAllImages,
                child: const Text('Remove All Pictures'),
              ),
            ),
          ),
          //This displays all the images on board and adds them to the matrix list,
          //which enables the moving and resizing of the images.
          for (int i = 0; i < _selectedImages.length; i++)
            Positioned.fill(
              child: MatrixGestureDetector(
                shouldScale: true,
                shouldTranslate: true,
                onMatrixUpdate: (Matrix4 matrix, Matrix4 translationMatrix,
                    Matrix4 scaleMatrix, Matrix4 rotationMatrix) {
                  matrix = matrix.clone()..scale(_imageScaleFactor);
                  setState(() {
                    _imageMatrices[i] = matrix;
                  });
                },
                child: Transform(
                  transform: _imageMatrices[i],
                  child: Image.file(
                    _selectedImages[i],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
