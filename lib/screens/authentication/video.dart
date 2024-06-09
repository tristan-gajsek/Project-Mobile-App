import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_mobile_app/components/app_bar.dart';
import 'package:project_mobile_app/state.dart';
import 'package:provider/provider.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  
  File ? _selectedVideo;

  @override
  Widget build(BuildContext context) {
    var sharedState = Provider.of<SharedState>(context);
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: MainAppBar(title: 'Video'),
      ),
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async{
              await _pickVideoFromGallery();
              if (_selectedVideo != null) {
                Navigator.pop(context, _selectedVideo);
              }
            },
            child: const Text('Select image from gallery'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _pickVideoFromCamera();
              if (_selectedVideo != null) {
                Navigator.pop(context, _selectedVideo);
              }
            },
            child: const Text('Take image with camera'),
          ),
          const SizedBox(height: 20,),
          _selectedVideo == null ? const Text('No image selected') : Image.file(_selectedVideo!),
        ],
      ),
      ), 
    );
  }
  Future _pickVideoFromGallery() async {
    final returnedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if(returnedVideo ==  null) return;
    setState(() {
      _selectedVideo = File(returnedVideo!.path);
    });
  }

  Future _pickVideoFromCamera() async {
    final returnedVideo = await ImagePicker().pickVideo(source: ImageSource.camera);

    if(returnedVideo ==  null) return;
    setState(() {
      _selectedVideo = File(returnedVideo!.path);
    });
  }
}

