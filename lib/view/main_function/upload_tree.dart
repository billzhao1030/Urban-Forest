import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_forest/provider/account_provider.dart';
import 'package:urban_forest/provider/ai_response.dart';
import 'package:urban_forest/provider/form_request.dart';
import 'package:urban_forest/provider/tree.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/debug_format.dart';

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:urban_forest/view/main_function/take_picture.dart';
import 'package:urban_forest/utils/form_validation.dart';

import '../../utils/reference.dart';

class UploadTree extends StatefulWidget {
  const UploadTree({ Key? key, this.tree, required this.model, this.preLocation}) : super(key: key);

  final Tree? tree;
  final LatLng? preLocation;
  final AccountModel model;

  @override
  State<UploadTree> createState() => _UploadTreeState();
}

class _UploadTreeState extends State<UploadTree> {
  bool isAddTree = true;
  bool isAddFromMap = false;
  bool longDistanceMatter = true;

  bool enableGPS = false;

  bool locationLoading = false;
  bool imageProcessing = false;
  bool databaseUploading = false;
  double latitude = 0.0;
  double longitude = 0.0;

  String bestMatchStr = "";

  final _formKey = GlobalKey<FormState>(); // for validation

  // tree location related attribute controller
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _surburbController = TextEditingController();
  final TextEditingController _streetNameController = TextEditingController();

  // controller for tree scaling
  final TextEditingController _treeHeightTextController = TextEditingController();
  final TextEditingController _treeWidthTextController = TextEditingController();
  final TextEditingController _treeLengthTextController = TextEditingController();

  // controller for tree speices
  final TextEditingController _scientificController = TextEditingController();
  final TextEditingController _commonController = TextEditingController();
  String shortScientificName = "";
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

  // variable for storing edit tree
  var version = 1;
  var objectID = "";

  // variable for compare
  var orgLatitude = "";
  var orgLongitude = "";
  var orgStreet = "";
  var orgSuburb = "";
  var orgLocType = "";
  var orgLocClass = "";
  var orgLocCate = "";
  var orgAssetID = "";
  var orgComment = "";
  var orgCondition = "";
  var orgCommon = "";
  var orgScientific = "";
  var orgHeight = "";
  var orgWidth = "";
  var orgLength = "";

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _surburbController.dispose();
    _streetNameController.dispose();
    _treeHeightTextController.dispose();
    _treeWidthTextController.dispose();
    _treeLengthTextController.dispose();
    _scientificController.dispose();
    _commentController.dispose();
    _commonController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.preLocation != null) {
      var latitude = widget.preLocation!.latitude;
      var longitude = widget.preLocation!.longitude;
      _latitudeController.text = latitude.toStringAsFixed(6);
      _longitudeController.text = longitude.toStringAsFixed(6);
      isAddFromMap = true;

      Position position = Position(
        longitude: longitude, 
        latitude: latitude, 
        timestamp: null, 
        accuracy: 0, 
        altitude: 0, 
        heading: 0, 
        speed: 0, 
        speedAccuracy: 0
      );
      getAddress(position);
    } else {
      if (widget.tree == null) {
        debugState("Is add");
        isAddTree = true;

        processLocation();
      } else {
        debugState("Is edit");
        isAddTree = false;

        editControllerPreset();
      }
    }

    super.initState();
    _locClassDropDown = setDropDown(locClassItems);
    _locCategoryDropDown = setDropDown(locCategoryItems);
    _treeLocDropDown = setDropDown(treeLocItems);
  }

  // set the three drop down menu
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
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.green, // primary color
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: !isAddTree || isAddFromMap, // if edit then add back button
        ),
        body: GestureDetector(
          onTap: () {
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: backgroundDecoration(
            context, 
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 24, 8, 8),
                child: Form(
                  key: _formKey,
                  child: treeFormColumn()
                ),
              )
            ),
            dismiss: false // let dismiss manual
          ),
        ),
      ),
    );
  }

  Column treeFormColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06
        ),
        // title
        isAddTree ? formText("Add a tree", fontsize: 28) : formText("Edit the tree", fontsize: 28),

        // get the location button
        const SizedBox(height: 10),
        isAddFromMap ? Container() : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isAddTree ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () async {
                  processLocation();
                }, 
                child: !locationLoading 
                  ? formText((isAddTree ? "Get location" : "Correct Location"), fontsize: 18, fontStyle: FontStyle.italic)
                  : Center(
                    child: Transform.scale(
                      scale: 0.75,
                      child: const CircularProgressIndicator(
                        color:Colors.white, strokeWidth: 4.0,)
                      )
                    )
              ),
            ),

            // The location advice and instruction
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return locationFetchAdvice();
                  }
                );
              }, 
              child: const Icon(
                Icons.question_mark_outlined,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                primary: const Color.fromARGB(1, 1, 1, 1),
              ),
            )
          ],
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
            footer: const Center(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text("Notice that the geolocation of the tree is automatically get (and is read-only)\n"
                "Please hold your mobile device as close to the tree as possible to ensure the high accuracy", textAlign: TextAlign.center,),
              ),
            ),
            margin: const EdgeInsets.all(4.0),
            children: [
              //latitude and longtitude
              treeLocation("Latitude", "Latitude (read only))", _latitudeController),
              treeLocation("Longtitude", "Longtitude (read only)", _longitudeController),
              treeAddress("Street", "Street name", _streetNameController),
              treeAddress("Suburb", "Locality", _surburbController)
            ],
          ),
        ),

        // camera and gallery function
        const SizedBox(height: 30),
        formText("Upload a photo to identify the tree"),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.42,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      imageProcessing = true;
                      debugState(imageProcessing.toString());
                    });
                    await takePicture();
                  }, 
                  child: formText("Take a photo", fontsize: 18, fontStyle: FontStyle.italic)
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.42,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      imageProcessing = true;
                      debugState(imageProcessing.toString());
                    });
                    await getFromGallery();
                  }, 
                  child: formText("Pick a photo", fontsize: 18, fontStyle: FontStyle.italic)
                ),
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            formText("How to upload good photo?", fontsize: 16,
             fontStyle: FontStyle.italic, fontColor: Colors.black54),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    return imageFetchAdvice();
                  }
                );
              }, 
              child: const Icon(
                Icons.question_mark_outlined,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                primary: const Color.fromARGB(1, 1, 1, 1),
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
            footer: const Center(
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text("Notice that the AI image recognition may not 100% accurate, please perform human check if possible", textAlign: TextAlign.center,),
              ),
            ),
            margin: const EdgeInsets.all(4.0),
            children: [
              treeSpecies("Common Name", "Common name", _commonController),
              treeSpecies("Scientific Name", "Scientific name", _scientificController),
            ],
          ),
        ),

        // tree location details
        const SizedBox(height: 15),
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
        (globalLevel > 1) ? const SizedBox(height: 10) : Container(),
        (globalLevel > 1) ? assetIDsection(_assetIDController) : Container(),

        // tree scale
        const SizedBox(height: 15),
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
                child: Text("All fields in this section are measured in meter(s)", textAlign: TextAlign.center,),
              )
            ),
            margin: const EdgeInsets.all(4.0),
            children: [
              treeScale("Height", "Tree height (e.g. 3.5)", _treeHeightTextController),
              treeScale("Width", "Tree width (e.g. 2.7)", _treeWidthTextController),
              treeScale("Length", "Tree length (e.g. 1.5)", _treeLengthTextController),
            ],
          ),
        ),

        // condition and comment
        const SizedBox(height: 15),
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


        const SizedBox(height: 20,),
        // submit button
        Row(
          mainAxisAlignment: (globalLevel > 1) && widget.model.toArcGIS! 
            ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.42,
              height: 45,
              
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (!isAddTree && !compareEditChange()) {
                      showHint(context, "Data didn't change!");
                    } else {
                      setState(() {
                        databaseUploading = true;
                      });

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return requestUploadAlert(context, true);
                        },
                        barrierDismissible: false
                      );
                    }
                  } else {
                    showHint(context, "Please use correct form of/complete the compulsory form field");
                  }
                },
                child: !databaseUploading 
                  ? formText((globalLevel > 1) ? "To Firebase" : "Submit", fontsize: 22, fontStyle: FontStyle.italic)
                  : const CircularProgressIndicator(color: Colors.white,),
              ),
            ),

            // To ArcGIS button
            (globalLevel > 1) && widget.model.toArcGIS!
              ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.42,
              height: 45,
              
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    //debugState("$isAddTree");
                    if (!isAddTree && !compareEditChange()) {
                      showHint(context, "Data didn't change!");
                    } else {
                      setState(() {
                        databaseUploading = true;
                      });

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return requestUploadAlert(context, false);
                        },
                        barrierDismissible: false
                      );
                    }
                  } else {
                    showHint(context, "Please use correct form of/complete the compulsory form field");
                  }
                },
                child: !databaseUploading 
                  ? formText("To ArcGIS", fontsize: 22, fontStyle: FontStyle.italic)
                  : const CircularProgressIndicator(color: Colors.white,),
              ),
            )
            : const SizedBox.shrink(),
          ],
        ),

        const SizedBox(height: 20,),
      ],
    );
  }

  // location suggestion
  AlertDialog locationFetchAdvice() {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/location_instruction.jpg",
              fit: BoxFit.fitHeight,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: normalText(
                "* Notice that the GPS location of the tree is obtained from you "
                "mobile device. So it's very important to keep your device as close "
                "to the tree as possible",
                isJust: true
              ),
            )
          ],
        ),
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
      setState(() {
        locationLoading = false;
      });
      denyGPS();
      return Future.error('Location services are disabled.');
    }

    // then check if allow the geolocator 
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        denyGPS();
        return Future.error('Location permissions are denied');
      }
    }
    
    // if the permission is permanently denied
    if (permission == LocationPermission.deniedForever) { 
      denyGPS();
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  Future<dynamic> denyGPS() {
    return showDialog(
      context: context, 
      builder: (BuildContext context) {
        return geolocatorEnabled(context);
      }
    );
  }

  // process the form data and upload to the database (firebase/ArcGIS)
  processForm(bool isFirebase) async {
    var uid = FirebaseAuth.instance.currentUser!.uid;

    Map<String, Object?> userRequests = {}; 

    if (isAddTree) {
      userRequests["requestAdd"] = widget.model.modelUser.requestAdd + 1;
    } else {
      userRequests["requestUpdate"] = widget.model.modelUser.requestUpdate + 1;
    }

    if (globalLevel > 1 && !isFirebase) {
      userRequests["requestAccepted"] = widget.model.modelUser.requestAccepted + 1;
    }

    dbUser.doc(uid).update(userRequests);

    await widget.model.getUser();

    if (!isFirebase) {
      await uploadToArcGIS();
      
      setState(() {
        databaseUploading = false;
      });

      showHint(context, "Request uploaded to ArcGIS!");
    } else {
      TreeRequest request = TreeRequest();
      request.isAdd = isAddTree;

      // get the tree and set the version to 1
      request.tree = isAddTree ? Tree() : widget.tree!;
      Tree requestTree = request.tree;
      requestTree.version = isAddTree ? 1 : (requestTree.version + 1);
      request.requestUID = uid;
      request.requestEmail = widget.model.modelUser.emailAddress;
      request.requestTime = DateTime.now().millisecondsSinceEpoch;

      await controllerToTree(requestTree);

      request.toTable();

      // add the tree to the firebase
      await request.uploadFirebase();
      await Future.delayed(const Duration(milliseconds: 100));

      setState(() {
        databaseUploading = false;
      });

      showHint(context, "Request uploaded to Firebase!");
    }

    resetForm();

    if (!isAddTree || isAddFromMap) {
      await Future.delayed(const Duration(milliseconds: 1500));
      // hide the current snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      Navigator.pop(context);
    }
  }

  // compare changes
  bool compareEditChange() {
    bool isChanged = false;
    //debugState("$orgAssetID, ${_assetIDController.text}");
    if (orgLocCate == locCategory &&
        orgLocClass == locClass &&
        orgLocType == treeLoc &&
        orgComment == _commentController.text && 
        orgCondition == _conditionController.text &&
        orgHeight == _treeHeightTextController.text &&
        orgLength == _treeLengthTextController.text &&
        orgWidth == _treeWidthTextController.text &&
        orgLatitude == _latitudeController.text &&
        orgLongitude == _longitudeController.text &&
        orgStreet == _streetNameController.text &&
        orgSuburb == _surburbController.text &&
        orgAssetID == _assetIDController.text &&
        orgCommon == _commonController.text &&
        orgScientific == _scientificController.text) {
      debugState("Same");
    } else {
      debugState("Changed");
      isChanged = true;
    }
    return isChanged;
  }


  // reset the whole tree form after comfirming upload
  void resetForm() {
    debugState("reset controller");

    _latitudeController.clear();
    _longitudeController.clear();
    _streetNameController.clear();
    _surburbController.clear();

    _scientificController.clear();
    _commonController.clear();

    _treeWidthTextController.clear();
    _treeLengthTextController.clear();
    _treeHeightTextController.clear();

    _commentController.clear();
    _conditionController.clear();

    _assetIDController.clear();

    bestMatchStr = "";
  }

  // get image from gallery
  getFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null){
      showHint(context, "No image selected!");
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
      showHint(context, "No image taken!");
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
      if (predict.accuracyList[0] >= 5) {
        setState(() {
          bestMatchStr = "Best Match: ${predict.scientificName[0]}\n"
          "With accuracy of: ${predict.bestAccuracy.toStringAsFixed(3)}%\n";

          // auto fill text field
          _commonController.text = predict.commonName[0].toUpperCase();
          _scientificController.text = predict.bestMatch;
          shortScientificName = predict.scientificName[0];
        });
      } else {
        setState(() {
          bestMatchStr = "Bad image, please take another one";
          _commonController.text = "";
          _scientificController.text = "";
          shortScientificName = "";
        });
      }
    } else {
      debugState("wrong image");
      setState(() {
        bestMatchStr = "Not a tree! Please take another one";
        _commonController.text = "";
        _scientificController.text = "";
        shortScientificName = "";
      });
    }
    
    setState(() {
      imageProcessing = false;
    });
  }

  // set the location from GPS
  processLocation() async {
    setState(() {
      locationLoading = true;
    });

    // get the geolocation
    Position position = await _determinePosition();
    latitude = position.latitude;
    longitude = position.longitude;

    debugState("latitude: $latitude");
    debugState("longitude: $longitude");

    bool willUpdateLocation = true;

    if (!isAddTree) {
      var oldLatitude = widget.tree!.latitude;
      var oldLongitude = widget.tree!.longitude;

      var distance = Geolocator.distanceBetween(oldLatitude, oldLongitude, latitude, longitude);

      if (distance > 10 && longDistanceMatter) {
        willUpdateLocation = await _longDistanceWarning(context, distance);
        debugState("will update: $willUpdateLocation");
      }
    }

    setState(() {
      locationLoading = false;
    });

    if (willUpdateLocation) {
      setState(() {
        longDistanceMatter = false;
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
      }); 
      getAddress(position);
    } 
  }

  Future<bool> _longDistanceWarning(BuildContext context, double distance) async {
    return await showDialog(
      context: context, 
      builder: (BuildContext context) => longDistanceAlert(context, distance)
    );
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


  // read and fill the relavant controller when editing
  editControllerPreset() {
    Tree editTree = widget.tree!;

    setState(() {
      orgCommon = _commonController.text = editTree.commonName;
      orgScientific = _scientificController.text = editTree.scientificName;

      orgLatitude = _latitudeController.text = editTree.latitude.toStringAsFixed(6);
      orgLongitude = _longitudeController.text = editTree.longitude.toStringAsFixed(6);
      orgStreet = _streetNameController.text = editTree.streetName;
      orgSuburb = _surburbController.text = editTree.suburb;

      if (editTree.height != 0) {
        orgHeight = _treeHeightTextController.text = editTree.height.toString();
      }

      if (editTree.length != 0) {
        orgLength = _treeLengthTextController.text = editTree.length.toString();
      }

      if (editTree.width != 0) {
        orgWidth = _treeWidthTextController.text = editTree.width.toString();
      }

      orgAssetID = _assetIDController.text = editTree.ASSNBRI;

      if (editTree.locCategory == null) {
        locCategory = "Rural";
      } else {
        locCategory = "Urban";
      }
      orgLocCate = locCategory;

      if (editTree.locClass == null || !editTree.locClass!.contains("Roads")) {
        locClass = "Not Applicable";
      } else {
        locClass = "Roads";
      }
      orgLocClass = locClass;

      if (editTree.locType.toUpperCase().contains("STREET")) {
        treeLoc = "Street";
      } else {
        treeLoc = "Park";
      }
      orgLocType = treeLoc;
    });
  }

  uploadToArcGIS() async {
    var token = await getToken();

    Tree requestTree = isAddTree ? Tree() : widget.tree!;

    requestTree.version = isAddTree ? 1 : (requestTree.version + 1);

    controllerToTree(requestTree);


    // user REST to upload
    http.MultipartRequest requestFeature;
    if (isAddTree) {
      requestFeature = http.MultipartRequest("POST", Uri.parse(
        "https://services.arcgis.com/yeXpdyjk3azbqItW/arcgis/rest/services/TreeDatabase/FeatureServer/24/addFeatures?f=json&token=$token")
      );
    } else {
      requestFeature = http.MultipartRequest("POST", Uri.parse(
        "https://services.arcgis.com/yeXpdyjk3azbqItW/arcgis/rest/services/TreeDatabase/FeatureServer/24/updateFeatures?f=json&token=$token")
      );
    }


    var data = treeToJson(requestTree);
    requestFeature.fields['features'] = jsonEncode(data);

    var send = await requestFeature.send();
    var response = await http.Response.fromStream(send);

    var json = jsonDecode(response.body);
    debugState(json.toString());
  }

  getToken() async {
    String token = "";
    final response = await http.get(Uri.parse(
      "https://www.arcgis.com/sharing/generateToken?username=xunyiz@utas.edu.au&password=$tokenPass&referer=launceston.maps.arcgis.com&f=json"
    ));
    var json = jsonDecode(response.body);
  
    token = json['token'].toString();
    debugState("token:$token");

    return token;
  }

  controllerToTree(Tree requestTree) async {
    // set the species fields
    requestTree.scientificName = _scientificController.text.trim();
    requestTree.shortScientificName = shortScientificName.trim();
    requestTree.commonName = _commonController.text.toUpperCase().trim();

    // set location 
    requestTree.latitude = double.parse(_latitudeController.text.trim());
    requestTree.longitude = double.parse(_longitudeController.text.trim());

    requestTree.suburb = _surburbController.text.trim();
    requestTree.streetName = _streetNameController.text.trim();

    // set location class
    requestTree.locClass = locClass;
    requestTree.locCategory = locCategory.contains("Urban") ? locCategory : "";
    requestTree.locType = treeLoc.toUpperCase(); 

    // set scale
    if (_treeHeightTextController.text.isNotEmpty) {
      requestTree.height = double.parse(_treeHeightTextController.text.trim());
    }
    if (_treeLengthTextController.text.isNotEmpty) {
      requestTree.length = double.parse(_treeLengthTextController.text.trim());
    }
    if (_treeWidthTextController.text.isNotEmpty) {
      requestTree.width = double.parse(_treeWidthTextController.text.trim());
    }

    // condition and comment
    if (_commentController.text.isNotEmpty) {
      requestTree.comment = _commentController.text.trim();
    }
    if (_conditionController.text.isNotEmpty) {
      requestTree.condition = _conditionController.text.trim();
    }

    var addSize = 0;
    await dbRequests.where("ASSNBRI", isGreaterThan: "999999").get().then((value) {
      addSize = (value.size)+1;
    });

    requestTree.ASSNBRI = (globalLevel > 1) ? _assetIDController.text.trim() : "np$addSize";

    requestTree.last_edite = FirebaseAuth.instance.currentUser!.email!; // write the last edit email in db

    // date related
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    debugState("The time upload: ${timestamp.toString()}");

    requestTree.COMM_DATEI = timestamp;
    requestTree.CRDATEI = timestamp;
    requestTree.LAST_MOD_D = timestamp;
    requestTree.LAST_RPT_U = timestamp;
    requestTree.last_edi_1 = timestamp;
  }

  treeToJson(Tree tree) {
    var attributes = {
      "VERS": tree.version,
      "ASSNBRI": tree.ASSNBRI,
      "DESCR": tree.scientificName,
      "SEARCH_DES": tree.commonName,
      "LONG_DESCR": tree.longScientificName,
      "SHORT_DESC": tree.shortScientificName,
      "BARCODE": tree.BARCODE,
      "ASSET_STAT": tree.ASSET_STAT,
      "DEPR_ASSET": tree.DEPR_ASSET,
      "ACQN_DATEI": tree.ACQN_DATEI,
      "EXP_COMM_D": tree.EXP_COMM_D,
      "COMM_DATEI": tree.COMM_DATEI,
      "DISPOSAL_D": tree.DISPOSAL_D,
      "SUPP_METH_": tree.SUPP_METH,
      "SUPP_NAME": tree.SUPP_NAME,
      "SUPP_REF": tree.SUPP_REF,
      "COMMENT1": tree.COMMENT1,
      "COMMENT2": tree.COMMENT2,
      "COMMENT3": tree.COMMENT3,
      "MANUF_NAME": tree.MANUF_NAME,
      "OTHER_NBR": tree.OTHER_NBR,
      "CRUSER": tree.CRUSER,
      "CRDATEI": tree.CRDATEI,
      "CRTIMEI": tree.CRTIMEI,
      "CRTERM": tree.CRTERM,
      "CRWINDOW": tree.CRWINDOW,
      "LAST_MOD_U": tree.LAST_MOD_U,
      "LAST_MOD_D": tree.LAST_MOD_D,
      "LAST_MOD_T": tree.LAST_MOD_T,
      "LAST_MOD_1": tree.LAST_MOD_1,
      "LAST_MOD_W": tree.LAST_MOD_W,
      "ASSET_RID": tree.ASSET_RID,
      "OPERATING_": tree.OPERATING_,
      "PRIMARY_AT": tree.PRIMARY_AT,
      "GIS_ID": tree.GIS_ID,
      "LAST_RPT_U": tree.LAST_RPT_U,
      "LAST_RPT_1": tree.LAST_RPT_1,
      "ConstructM": tree.ConstructM,
      "AssetSourc": tree.AssetSourc,
      "TreeLocati": tree.locType,
      "WateringMe": tree.WateringMe,
      "LengthDime": tree.length,
      "WidthDimen": tree.width,
      "HeightDime": tree.height,
      "AreaDimens": tree.area,
      "CapitalPro": tree.CapitalPro,
      "Class": tree.Class_,
      "Category": tree.Category,
      "Grp": tree.Grp,
      "Facility": tree.Facility,
      "LocClass": tree.locClass,
      "LocCat": tree.locCategory,
      "LocGrp": tree.streetName,
      "Suburb": tree.suburb,
      "Network": tree.Network,
      "Team": tree.Team,
      "CostCentre": tree.CostCentre,
      "LCCLeases": tree.LCCLeases,
      "MaintZoneC": tree.MaintZoneC,
      "MaintZon_1": tree.MaintZon_1,
      "Condition": tree.condition,
      "MaintCycle": tree.MaintCycle,
      "GlobalID": tree.GlobalID,
      "created_us": tree.create_us,
      "created_da": tree.created_da,
      "last_edite": tree.last_edite,
      "last_edi_1": tree.last_edi_1,
    };

    if (!isAddTree) {
      attributes["OBJECTID"] = tree.objectID;
    }

    var data = [
      {
        "attributes": attributes,
        "geometry": {
          "x": tree.longitude,
          "y": tree.latitude,
        }
      }
    ];

    return data;
  }

  AlertDialog geolocatorEnabled(BuildContext context) {
    return AlertDialog(
      title: const Text('GPS service'),
      content: const Text('Please enable the GPS service to access the rest functions'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            SystemNavigator.pop();
          },
          child: const Text(
            'OK',
            style: TextStyle(
              fontSize: 22
            ),
          ),
        ),
      ],
    );
  }

  AlertDialog longDistanceAlert(BuildContext context, double distance) {
    return AlertDialog(
      title: const Text('Pay attention'),
      content: Text(
        'You are ${distance.toStringAsFixed(1)} metres away from this tree. '
        'The new geolocation might be inaccurate, please get closer to the tree and try again, '
        'or keep the old geolocation'
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text(
            'Never mind',
            style: TextStyle(
              fontSize: 22
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text(
            'OK',
            style: TextStyle(
              fontSize: 22
            ),
          ),
        ),
      ],
    );
  }

  // request tree confirm
  AlertDialog requestUploadAlert(BuildContext context, bool isFirebase) {
    return AlertDialog(
      title: isAddTree ? const Text('Upload a new tree') : const Text('Edit an existing tree'),
      content: const Text('Confirm this request?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            setState(() {
              databaseUploading = false;
            });

            Navigator.pop(context);
          },
          child: const Text(
            'No',
            style: TextStyle(
              fontSize: 22
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            
            processForm(isFirebase);
          },
          child: const Text(
            'Yes',
            style: TextStyle(
                fontSize: 22
            ),
          ),
        ),
      ],
    );
  }

  // image suggestion dialog
  AlertDialog imageFetchAdvice() {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/image_instruction.png",
              fit: BoxFit.fitHeight,
            ),
          ],
        ),
      ),
    );
  }

  Padding assetIDsection(TextEditingController _controller) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: CupertinoFormSection(
          backgroundColor: const Color.fromARGB(177, 231, 226, 226),
          header: const Text(
            "Tree Identifier", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)
          ),
          footer: const Center(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text("Tree Asset ID (ASSNBRI), please make sure this is the unique ID in the database"),
            ),
          ),
          margin: const EdgeInsets.all(4.0),
          children: [
            CupertinoTextFormFieldRow(
              controller: _controller,
              prefix: SizedBox(
                width: MediaQuery.of(context).size.width * 0.32,
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                return validateAssetID(value);
              },
            )
          ]
        ),
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
          width: MediaQuery.of(context).size.width * 0.4,
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
        width: MediaQuery.of(context).size.width * 0.35,
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
      keyboardType: TextInputType.text,
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        return validateScale(value);
      }
    );
  }
}
