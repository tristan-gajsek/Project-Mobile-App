import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_mobile_app/components/app_bar.dart';
import 'package:project_mobile_app/state.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  
  File ? _selectedImage;

  @override
  Widget build(BuildContext context) {
    var sharedState = Provider.of<SharedState>(context);
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MainAppBar(title: 'Camera'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _pickImageFromGallery();
            },
            child: const Text('Select image from galery'),
          ),
          ElevatedButton(
            onPressed: () {
              _pickImageFromGallery();
            },
            child: const Text('Take image with camera'),
          ),
          const SizedBox(height: 20,),
          _selectedImage == null ? const Text('No image selected') : Image.file(_selectedImage!),
        ],
      ),
    );
  }

  Future _pickImageFromGallery() async {
  final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(returnedImage ==  null) return;
    setState(() {
      _selectedImage = File(returnedImage!.path);
    });
  }

  Future _pickImageFromCamera() async {
  final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if(returnedImage ==  null) return;
    setState(() {
      _selectedImage = File(returnedImage!.path);
    });
  }
}

