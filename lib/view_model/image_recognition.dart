import 'dart:convert';

import 'dart:developer';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'dart:io';

import 'package:http/http.dart';

import 'package:image_picker/image_picker.dart';

const String apiAIKey = "2b100KCG6O3OeIMqokoAQCliz";
const apiAIRecognition = "https://my-api.plantnet.org/v2/identify/all?api-key=$apiAIKey";

class AITemp extends StatefulWidget {
  const AITemp({ Key? key }) : super(key: key);

  @override
  State<AITemp> createState() => _AITempState();
}

class _AITempState extends State<AITemp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  getFromGallery();
                },
                child: Text('gallery'),
              ),  
              ElevatedButton(
                onPressed: () async {
                  takePicture();
                }, 
                child: Text("camera")
              )          
            ],
          ),
        )
      ),
    );
  }



  void getFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;

    uploadImage(image);
  }

  void takePicture() async {
    final camera = await availableCameras();

    final firstCamera = camera.first;
    var image = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePictureScreen(camera: firstCamera))
    );
    if (image == null) return;

    uploadImage(image);
  }

  uploadImage(XFile image) async {
    log("can here");
    var request = http.MultipartRequest("POST", Uri.parse(apiAIRecognition));
    request.files.add(await MultipartFile.fromPath("images", image.path));

    var response = await request.send();

    var str = await http.Response.fromStream(response);

    var json = jsonDecode(str.body);

    log(json.toString());

    // log(json['results'][0].toString());
    // log("=====");
    // log(json['results'][1].toString());
    // log("=====");
  }
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  const TakePictureScreen({Key? key, required this.camera}) : super(key: key);

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();
            Navigator.pop(context, image);
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Display the Picture")),
      body: Image.file(File(imagePath)),
    );
  }
}