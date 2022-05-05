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
import 'package:urban_forest/view_model/form_validation.dart';

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

  // controller for tree speices
  final TextEditingController _scentificController = TextEditingController();
  final TextEditingController _commonController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: backgroundDecoration(
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
      ),
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
    //debugState(place.toString());

    setState(() {
      _surburbController.text = place.locality.toString();
      _streetNameController.text = place.street.toString();
    });
  }

  Column treeFormColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.04
        ),
        // title
        formText("Add a tree", fontsize: 28),

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
                  child: formText("Take a photo", fontsize: 15)
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
                  child: formText("Choose a photo", fontsize: 15)
                ),
              ),
            ),
          ],
        ),

        // the temp response (display somewhere else)
        !imageProcessing 
          ? (bestMatchStr.isEmpty 
            ? Container() 
            : formText(bestMatchStr, fontsize: 15, fontStyle: FontStyle.italic))
          : const CircularProgressIndicator(),

        // tree species information
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoFormSection(
            backgroundColor: const Color.fromARGB(177, 231, 226, 226),
            header: const Text(
              "Tree species", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)
            ),
            margin: const EdgeInsets.all(4.0),
            children: [
              treeSpecies("Common Name", "Common name", _commonController),
              treeSpecies("Scentific Name", "Sentific name", _scentificController),
            ],
          ),
        ),

        // tree basic information
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoFormSection(
            backgroundColor: const Color.fromARGB(177, 231, 226, 226),
            header: const Text(
              "Tree location", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)
            ),
            margin: const EdgeInsets.all(4.0),
            children: [
              //latitude and longtitude
              treeLocation("Latitude", "Latitude of tree", _latitudeController),
              treeLocation("Longtitude", "Longtitude of tree", _longtitudeController),
              treeAddress("Street", "Street name", _streetNameController),
              treeAddress("Surburb", "Locality", _surburbController)

              //TODO:radio button of road/not, urban/empty
            ],
          ),
        ),

        // get the location button
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          child: ElevatedButton(
            onPressed: () async {
              setState(() {
                locationLoading = true;
              });

              // get the geolocation
              Position position = await _determinePosition();
              latitude = position.latitude;
              longtitude = position.longitude;

              getAddress(position);

              setState(() {
                locationLoading = false;
                _latitudeController.text = position.latitude.toStringAsFixed(6);
                _longtitudeController.text = position.longitude.toStringAsFixed(6);
              }); 
            }, 
            child: !locationLoading 
              ? formText("Get location", fontsize: 18, fontStyle: FontStyle.italic)
              : const Center(child: CircularProgressIndicator(color:Colors.white, strokeWidth: 3.0,))
          ),
        ),

        // tree scale
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoFormSection(
            backgroundColor: const Color.fromARGB(177, 231, 226, 226),
            header: const Text(
              "Tree scale (Optional)", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)
            ),
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
              var width = _treeWidthTextController.text.trim();
              var length = _treeLengthTextController.text.trim();
              if (width.isNotEmpty && length.isNotEmpty) {
                _treeAreaTextController.text = (double.parse(width) * double.parse(length)).toString();
              }
              if (_formKey.currentState!.validate()) {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const ConfirmSubmit(),
                //   )
                // );
                debugState("okay");
              }
            },
            child: formText("Submit", fontsize: 22, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  // tree address row
  CupertinoTextFormFieldRow treeSpecies(String prefix, String placeHolder, TextEditingController _controller) {
    return CupertinoTextFormFieldRow(
      controller: _controller,
      prefix: SizedBox(
        width: MediaQuery.of(context).size.width * 0.28,
        child: formText(prefix, fontColor: CupertinoColors.black, fontsize: 16)
      ),
      obscureText: false,
      maxLines: 1,
      autocorrect: true,
      enableSuggestions: true,
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black.withOpacity(0.88)),
      placeholder: placeHolder,
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.streetAddress,
      maxLength: 40,
      validator: (value) {
        return validateSpecies(value);
      },
    );
  }

  // tree address row
  CupertinoTextFormFieldRow treeAddress(String prefix, String placeHolder, TextEditingController _controller) {
    return CupertinoTextFormFieldRow(
      controller: _controller,
      prefix: SizedBox(
        width: MediaQuery.of(context).size.width * 0.28,
        child: formText(prefix, fontColor: CupertinoColors.black, fontsize: 16)
      ),
      obscureText: false,
      maxLines: 1,
      autocorrect: true,
      enableSuggestions: true,
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black.withOpacity(0.88)),
      placeholder: placeHolder,
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: TextInputType.streetAddress,
      maxLength: 40,
      validator: (value) {
        return validateAddress(value);
      },
    );
  }

  // latitude and longtitude
  CupertinoTextFormFieldRow treeLocation(String prefix, String placeHolder, TextEditingController _controller) {
    return CupertinoTextFormFieldRow(
      controller: _controller,
      prefix: SizedBox(
        width: MediaQuery.of(context).size.width * 0.28,
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
      maxLength: 11,
      readOnly: true,
      validator: (value) {
        return validateGPS(value);
      },
    );
  }

  // form row of tree scale: height, width, length, area(read only)
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
      validator: (value) {
        return validateScale(value);
      }
    );
  }

  // get image from gallery
  getFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null){
      setState(() {
        imageProcessing = false;
      });
      return;
    }

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
    if (image == null) {
      setState(() {
        imageProcessing = false;
      });
      return;
    }

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
      if (predict.accuracyList[0] >= 25) {
        setState(() {
          // set the predict string
          // var commonNames = "";
          // var scientificNames = "";
          // for (var cName in predict.commonName) {
          //   commonNames += "$cName\n";
          // }
          // for (var sName in predict.scientificName) {
          //   scientificNames += "$sName\n";
          // }

          bestMatchStr = "Best Match: ${predict.scientificName[0]}\n"
          "With accuracy of: ${predict.bestAccuracy}%\n";
          // "Possible Scientific name:\n$scientificNames"
          // "Possible Common name\n$commonNames";

          // auto fill text field
          _commonController.text = predict.commonName[0].toUpperCase();
          _scentificController.text = predict.scientificName[0];
        });
      }
    } else {
      debugState("wrong image");
      setState(() {
        bestMatchStr = "Bad image, please take another one";
      });
    }
    
    setState(() {
      imageProcessing = false;
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