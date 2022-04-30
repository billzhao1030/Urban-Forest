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
import 'package:geocoding/geocoding.dart';
import 'package:urban_forest/view/main_function/take_picture.dart';
import 'package:urban_forest/view/main_function/tree_form.dart/confirm_submission.dart';

import '../../../utils/color_utils.dart';
import '../../../utils/reference.dart';

class AddTree extends StatefulWidget {
  const AddTree({ Key? key }) : super(key: key);

  @override
  State<AddTree> createState() => _AddTreeState();
}

class _AddTreeState extends State<AddTree> {
  bool enableGPS = false;

  bool locationLoading = false;
  bool imageProcessing = false;
  double latitude = 0.0;
  double longtitude = 0.0;

  String bestMatchStr = "";

  final _formKey = GlobalKey<FormState>(); // for validation

  // tree location related attribute controller
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longtitudeController = TextEditingController();
  final TextEditingController _surburbController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();

  // controller for tree scaling
  final TextEditingController _treeHeightTextController = TextEditingController();
  final TextEditingController _treeWidthTextController = TextEditingController();
  final TextEditingController _treeLengthTextController = TextEditingController();
  final TextEditingController _treeAreaTextController = TextEditingController();

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

  // get current position
  Future _determinePosition() async {
    /*
    Three error cases
    1. GPS disabled
    2. Permanently denied at first
    3. Denied after ask 
    */
    bool serviceEnabled;
    LocationPermission permission;

    // check if the GPS service is enabled 
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // then check if allow the geolocator 
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    // if the permission is permanently denied
    if (permission == LocationPermission.deniedForever) { 
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  // get address from position
  getAddress(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    var place = placemarks[0];
  }

  Column treeFormColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // title
        formText("Add a tree", fontsize: 28),

        // location area
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

        // camera and gallery function
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

        // the temp response (display somewhere else)
        !imageProcessing ? formText(bestMatchStr) : const CircularProgressIndicator(),

        // tree basic information
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoFormSection(
            header: const Text("Location of the tree"),
            margin: const EdgeInsets.all(4.0),
            children: [
              CupertinoTextFormFieldRow(
                controller: _latitudeController,
                prefix: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: formText("Latitude", fontColor: CupertinoColors.black, fontsize: 16)
                ),
                obscureText: false,
                autocorrect: true,
                enableSuggestions: true,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black.withOpacity(0.88)),
                placeholder: "Latitude",
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 8,
                readOnly: true,
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                locationLoading = true;
              });

              Position position = await _determinePosition();
              latitude = position.latitude;
              longtitude = position.longitude;

              setState(() {
                locationLoading = false;
              });

              getAddress(position);
            }, 
            child: formText("Get location", fontsize: 18, fontStyle: FontStyle.italic)
          ),
        ),

        // tree scale
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoFormSection(
            header: const Text("Tree scale (Optional)"),
            footer: const Center(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text("All fields in this section are measured in meter(s)"),
              )),
            margin: const EdgeInsets.all(4.0),
            children: [
              treeScaleFormRow("Height", "Tree height (e.g. 3.5)", _treeHeightTextController),
              treeScaleFormRow("Width", "Tree width (e.g. 2.7)", _treeWidthTextController),
              treeScaleFormRow("Length", "Tree length (e.g. 1.5)", _treeLengthTextController),
              treeScaleFormRow("Area", "Tree area (read only)", _treeAreaTextController, readOnly: true)
            ],
          ),
        ),

        // submit button
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfirmSubmit(),
                )
              );
            },
            child: formText("Submit", fontsize: 22, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  CupertinoTextFormFieldRow treeScaleFormRow(String prefix, String placeHolder, TextEditingController _controller, {bool readOnly = false}) {
    return CupertinoTextFormFieldRow(
      controller: _controller,
      prefix: SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        child: formText(prefix, fontColor: CupertinoColors.black, fontsize: 16)
      ),
      obscureText: false,
      autocorrect: true,
      enableSuggestions: true,
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black.withOpacity(0.88)),
      placeholder: placeHolder,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      maxLength: 4,
      readOnly: readOnly,
      // TODO: validator
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

  // the form text in cupertino
  DefaultTextStyle formText(String text, {
    double fontsize = 20, 
    FontStyle fontStyle = FontStyle.normal,
    Color fontColor = Colors.white
    }) {
    return DefaultTextStyle(
      textAlign: TextAlign.center,
      style: TextStyle(
        color: fontColor,
        fontSize: fontsize,
        fontWeight: FontWeight.bold,
        fontStyle: fontStyle,
      ),
      child: Text(text),
    );
  }
}