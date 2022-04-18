import 'dart:convert';

import 'dart:developer';
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
          child: ElevatedButton(
            onPressed: () async {
              getFromGallery();
            },
            child: Text('get'),
          ),
          )
      ),
    );
  }

  void getFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;

    var request = http.MultipartRequest("POST", Uri.parse(apiAIRecognition));
    request.files.add(await MultipartFile.fromPath("images", image.path));

    var response = await request.send();
    //final respStr = await response.stream.bytesToString();

    var str = await http.Response.fromStream(response);

    var json = jsonDecode(str.body);

    log(json['results'][0].toString());
    log("=====");
    log(json['results'][1].toString());
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Display the Picture")),
      body: Image.file(File(imagePath)),
    );
  }
}