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

class _BoardState extends State<Board> {
  List<Matrix4> _imageMatrices = [];
  List<File> _selectedImages = [];
  double _imageScaleFactor = 0.5;

  Future<void> _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImages.add(File(pickedImage.path));
        _imageMatrices.add(
            Matrix4.diagonal3Values(_imageScaleFactor, _imageScaleFactor, 1.0));
      });
    }
  }

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
