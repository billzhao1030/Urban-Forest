import 'dart:convert';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_forest/provider/ai_response.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/debug_format.dart';

import 'package:geolocator/geolocator.dart';
import 'package:urban_forest/view/main_function/take_picture.dart';

import '../../utils/reference.dart';

class AddTree extends StatefulWidget {
  const AddTree({ Key? key }) : super(key: key);

  @override
  State<AddTree> createState() => _AddTreeState();
}

class _AddTreeState extends State<AddTree> {
  bool imageProcessing = false;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) { 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return backgroundDecoration(
      context, 
      Padding(
        padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height * 0.08, 20, 0),
        child: Center(
          child: Column(
            children: [
              formText("Add a tree"),
              ElevatedButton(
                onPressed: () async {
                //  Position position = await _determinePosition();
                //  print(position.latitude);
                //  print(position.longitude);
                  showError(context, "hhh", 40);
                },
                child: formText("get")
              ),
              ElevatedButton(
                onPressed: () async {
                  takePicture();
                },
                child: formText("camera")
              ),
              ElevatedButton(
                onPressed: () async {
                  getFromGallery();
                },
                child: imageProcessing ? CircularProgressIndicator(color: Colors.white) : formText("pick")
              ),
            ],
          ),
        ),
      )
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
    setState(() {
      imageProcessing = true;
    });
    var request = http.MultipartRequest("POST", Uri.parse(apiAIRecognition));
    request.fields['organs'] = 'flower';
    request.files.add(await MultipartFile.fromPath("images", image.path));

    var response = await request.send();

    processResponse(await http.Response.fromStream(response));
  }

  processResponse(http.Response response) {
    var json = jsonDecode(response.body);

    final badImage = json['statusCode'].toString().contains("404");
    if (!badImage) {
      AIResponse predict = AIResponse.fromJson(json);
      predict.todebug();
    } else {
      debugState("wrong image");
    }
    
    setState(() {
      imageProcessing = false;
    });
  }

  DefaultTextStyle formText(String text, {double fontsize = 24, FontStyle fontStyle = FontStyle.normal}) {
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: fontsize,
        fontWeight: FontWeight.bold,
        fontStyle: fontStyle
      ),
      child: Text(text),
    );
  }
}