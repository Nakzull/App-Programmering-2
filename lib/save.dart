import 'package:app5/pictureOnBoard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);

  @override
  State<Board> createState() {
    return _BoardState();
  }
}

class _BoardState extends State<Board> {
  final List<File> _selectedImages = [];
  bool _showSelectedImages = false;

  Future<void> _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(
        () {
          _selectedImages.add(File(pickedImage.path));
          _showSelectedImages = true;
        },
      );
    }
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
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: const Text('Select Picture'),
              ),
            ),
          ),
          if (_showSelectedImages)
            Column(
              children: [
                for (File imageFile in _selectedImages)
                  PictureOnBoard(
                    child: Image.file(imageFile),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
