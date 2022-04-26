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
import 'package:urban_forest/view/main_function/tree_form.dart/confirm_submission.dart';

import '../../../utils/reference.dart';

class AddTree extends StatefulWidget {
  const AddTree({ Key? key }) : super(key: key);

  @override
  State<AddTree> createState() => _AddTreeState();
}

class _AddTreeState extends State<AddTree> {
  bool locationLoading = false;
  bool imageProcessing = false;
  double latitude = 0.0;
  double longtitude = 0.0;

  String bestMatchStr = "";

  final _formKey = GlobalKey<FormState>(); // for validation

  final TextEditingController _emailTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return backgroundDecoration(
      context, 
      Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
          child: Form(
            key: _formKey,
            child: treeFormColumn()
          ),
        )
      )
    );
  }

  // get image from gallery
  getFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;

    await uploadImage(image);
  }

  // get image from camera
  takePicture() async {
    final camera = await availableCameras();

    final firstCamera = camera.first;
    var image = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePictureScreen(camera: firstCamera))
    );
    if (image == null) return;

    await uploadImage(image);
  }

  // upload image to server and process the response
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
      setState(() {
        bestMatchStr = predict.bestMatch;
      });
    } else {
      debugState("wrong image");
      setState(() {
        bestMatchStr = "Bad image";
      });
    }
    
    setState(() {
      imageProcessing = false;
      debugState(imageProcessing.toString());
    });
  }

  // get current position
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

  DefaultTextStyle formText(String text, {
    double fontsize = 20, 
    FontStyle fontStyle = FontStyle.normal,
    Color fontColor = Colors.white
    }) {
    return DefaultTextStyle(
      style: TextStyle(
        color: fontColor,
        fontSize: fontsize,
        fontWeight: FontWeight.bold,
        fontStyle: fontStyle
      ),
      child: Text(text),
    );
  }

  Column treeFormColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        formText("Add a tree", fontsize: 28),

        const SizedBox(height: 10),
        formText("Your location:", fontColor: Colors.orangeAccent),

        const SizedBox(height: 10,),
        !locationLoading ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            formText("Latitude: ${latitude.toStringAsFixed(6)}    ", 
              fontsize: 16, fontColor: Colors.orangeAccent, fontStyle: FontStyle.italic),
            formText("Longtitude: ${longtitude.toStringAsFixed(6)}", 
              fontsize: 16, fontColor: Colors.orangeAccent, fontStyle: FontStyle.italic)
          ],
        ) : const CircularProgressIndicator(color: Colors.orangeAccent,),

        const SizedBox(height: 10),
        formText("Upload a photo to identify the tree"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.36,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      imageProcessing = true;
                      debugState(imageProcessing.toString());
                    });
                    await takePicture();
                  }, 
                  child: const Text("Take a photo")
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.36,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      imageProcessing = true;
                      debugState(imageProcessing.toString());
                    });
                    await getFromGallery();
                  }, 
                  child: const Text("Choose a photo")
                ),
              ),
            ),
          ],
        ),

        !imageProcessing ? formText(bestMatchStr) : const CircularProgressIndicator(),

        const SizedBox(height: 10),
        //CupertinoTextFormFieldRow()
        CupertinoFormSection(
          margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
          children: [
            CupertinoTextFormFieldRow(
              
              placeholder: "jj",
            ),
            CupertinoTextFormFieldRow(
              placeholder: "sajf",
            )
          ],
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ConfirmSubmit(),
              )
            );
          },
          child: const Text("submit"),
        )
      ],
    );
  }
  // child: Column(
          //   children: [
          //     formText("Add a tree"),
          //     ElevatedButton(
          //       onPressed: () async {
          //       //  Position position = await _determinePosition();
          //       //  print(position.latitude);
          //       //  print(position.longitude);
          //         showError(context, "hhh", 40);
          //       },
          //       child: formText("get")
          //     ),
          //     ElevatedButton(
          //       onPressed: () async {
          //         takePicture();
          //       },
          //       child: formText("camera")
          //     ),
          //     ElevatedButton(
          //       onPressed: () async {
          //         getFromGallery();
          //       },
          //       child: imageProcessing ? CircularProgressIndicator(color: Colors.white) : formText("pick")
          //     ),
          //   ],
          // ),
}