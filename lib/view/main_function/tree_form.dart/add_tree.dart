import 'dart:convert';

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
import 'package:urban_forest/view_model/form_validation.dart';

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

  // controller for tree speices
  final TextEditingController _scentificController = TextEditingController();
  final TextEditingController _commonController = TextEditingController();

  // controller for comments
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // dropdown menu
  List<DropdownMenuItem<String>> _locClassDropDown = [];
  List<DropdownMenuItem<String>> _locCategoryDropDown = [];
  List<DropdownMenuItem<String>> _treeLocDropDown = [];

  // access level 2 part
  final TextEditingController _assetIDController = TextEditingController();

  var locClass = "Roads";
  var locCategory = "Urban"; 
  var treeLoc = "Street";

  @override
  void initState() {
    super.initState();
    _locClassDropDown = setDropDown(locClassItems);
    _locCategoryDropDown = setDropDown(locCategoryItems);
    _treeLocDropDown = setDropDown(treeLocItems);

    debugState("access level: $globalLevel");
  }

  List<DropdownMenuItem<String>> setDropDown(List<String> list) {
    List<DropdownMenuItem<String>> items = [];

    for (String str in list) {
      items.add(DropdownMenuItem(
        value: str,
        child: formText(
          str, 
          fontsize: 16, 
          fontColor: Colors.black,
          fontStyle: FontStyle.italic  
        ),
      ));
    }

    return items;
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
                  child: formText("Take a photo", fontsize: 15, fontStyle: FontStyle.italic)
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
                  child: formText("Choose a photo", fontsize: 15, fontStyle: FontStyle.italic)
                ),
              ),
            ),
          ],
        ),

        // the simple response (display somewhere else)
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

        // get the location button
        const SizedBox(height: 5),
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

        // tree basic information
        const SizedBox(height: 5),
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
              treeLocation("Latitude", "Latitude (read only))", _latitudeController),
              treeLocation("Longtitude", "Longtitude (read only)", _longtitudeController),
              treeAddress("Street", "Street name", _streetNameController),
              treeAddress("Suburb", "Locality", _surburbController)
            ],
          ),
        ),

        // tree location details
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoFormSection(
            backgroundColor: const Color.fromARGB(177, 231, 226, 226),
            header: const Text(
              "Tree location classes", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)
            ),
            margin: const EdgeInsets.all(4.0),
            children: [
              // location class: roads or not
              dropDownMenus(
                "Location Class",
                DropdownButton<String> (
                  items: _locClassDropDown,
                  value: locClass,
                  itemHeight: 60,
                  enableFeedback: true,
                  alignment: AlignmentDirectional.center,
                  onChanged: (selected){
                    setState(() {
                      locClass = selected.toString();
                      //log(locClass.toString());
                    });
                  },
                ) 
              ),
              // location category: urban or not
              dropDownMenus(
                "Location Category",
                DropdownButton<String> (
                  items: _locCategoryDropDown,
                  value: locCategory,
                  itemHeight: 60,
                  enableFeedback: true,
                  alignment: AlignmentDirectional.center,
                  onChanged: (selected){
                    setState(() {
                      locCategory = selected.toString();
                      //log(locCategory.toString());
                    });
                  },
                ) 
              ),
              // tree location: street or park
              dropDownMenus(
                "Location Type",
                DropdownButton<String> (
                  items: _treeLocDropDown,
                  value: treeLoc,
                  itemHeight: 60,
                  enableFeedback: true,
                  alignment: AlignmentDirectional.center,
                  onChanged: (selected){
                    setState(() {
                      treeLoc = selected.toString();
                      //log(treeLoc.toString());
                    });
                  },
                ) 
              ),
            ],
          ),
        ),

        // asset id
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoFormSection(
            backgroundColor: const Color.fromARGB(177, 231, 226, 226),
            header: const Text(
              "Tree Identifier", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)
            ),
            margin: const EdgeInsets.all(4.0),
            children: [
              CupertinoTextFormFieldRow(
                controller: _assetIDController,
                prefix: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.37,
                  child: formText("Asset ID", fontColor: CupertinoColors.black, fontsize: 16)
                ),
                obscureText: false,
                autocorrect: true,
                enableSuggestions: true,
                cursorColor: Colors.black,
                style: TextStyle(color: Colors.black.withOpacity(0.88)),
                placeholder: "6 digits ID",
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autovalidateMode: AutovalidateMode.always,
                validator: (value) {
                  return validateAssetID(value);
                },
              )
            ]
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
              treeScale("Height", "Tree height (e.g. 3.5)", _treeHeightTextController),
              treeScale("Width", "Tree width (e.g. 2.7)", _treeWidthTextController),
              treeScale("Length", "Tree length (e.g. 1.5)", _treeLengthTextController),
            ],
          ),
        ),

        // condition and comment
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoFormSection(
            backgroundColor: const Color.fromARGB(177, 231, 226, 226),
            header: const Text(
              "Condition and comments (Optional)", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)
            ),
            margin: const EdgeInsets.all(4.0),
            children: [
              treeComment("Condition", "", _conditionController, maxLines: 2),
              treeComment("Comments", "", _commentController, maxLines: 3),
            ],
          ),
        ),

        // submit button
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.35,
          
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                processForm();
                
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

  // Three dropdown menus
  Row dropDownMenus(String prefix, Widget dropdown) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: formText(
            prefix, 
            fontColor: CupertinoColors.black, 
            fontsize: 16
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dropdown,
            ],
          )
        )
      ],
    );
  }

  // tree species row
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
      autovalidateMode: AutovalidateMode.always,
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
      autovalidateMode: AutovalidateMode.always,
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
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        return validateGPS(value);
      },
    );
  }

  // form row of tree comments
  CupertinoTextFormFieldRow treeComment(String prefix, String placeHolder, TextEditingController _controller, {int maxLines = 3}) {
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
      maxLength: 256,
      maxLines: maxLines
    );
  }

  // form row of tree scale: height, width, length, area(read only)
  CupertinoTextFormFieldRow treeScale(String prefix, String placeHolder, TextEditingController _controller, {bool readOnly = false}) {
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
      autovalidateMode: AutovalidateMode.always,
      validator: (value) {
        return validateScale(value);
      }
    );
  }


  // process the form data
  processForm() {
    //TreeRequest request = TreeRequest();

    
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

  // process image recognition
  processResponse(http.Response response) {
    var json = jsonDecode(response.body);

    final badImage = json['statusCode'].toString().contains("404");
    if (!badImage) {
      AIResponse predict = AIResponse.fromJson(json);
      predict.todebug();
      if (predict.accuracyList[0] >= 20) {
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

}