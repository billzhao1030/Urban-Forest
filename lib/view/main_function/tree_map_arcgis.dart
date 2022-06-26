// ignore_for_file: await_only_futures

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:urban_forest/provider/tree.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/view/main_function/upload_tree.dart';


class TreeMap extends StatefulWidget {
  const TreeMap({ Key? key, required this.controller }) : super(key: key);

  final CupertinoTabController controller;

  @override
  State<TreeMap> createState() => _TreeMapState();
}

class _TreeMapState extends State<TreeMap> {
  var marker = <Marker>{};
  var token = ""; // for map access

  var mapLoading = true;

  double currLatitude = 0;
  double currLongitude = 0;

  late BitmapDescriptor mapMarker;

  @override
  void initState() {
    //debugState("access level: $globalLevel");
    setMarker();
    dataLoading();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // hide the current snackbar
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: mapLoading 
                ? const Center(child: CircularProgressIndicator(),)
                : TreePointMap(marker: marker, longitude: currLongitude, latitude: currLatitude,),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: (){
            setState(() {
              mapLoading = true;
            });
            dataLoading();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );

  }

  Future _determinePosition() async {
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

  void setMarker() async {
    Uint8List? markerIcon = await getBytesFromAsset('assets/images/tree.png', 90);
    mapMarker = await BitmapDescriptor.fromBytes(markerIcon!);
  }

  dataLoading() async {
    // get location
    Position position = await _determinePosition();
    currLatitude = position.latitude;
    currLongitude = position.longitude;
    debugState("latitude: ${currLatitude.toStringAsFixed(6)}");
    debugState("longtitude: ${currLongitude.toStringAsFixed(6)}");

    // get token for oAuth
    token = "";
    final response = await http.get(Uri.parse(
      "https://www.arcgis.com/sharing/generateToken?username=xunyiz@utas.edu.au&password=dayi87327285&referer=launceston.maps.arcgis.com&f=json"
    ));
    var json = jsonDecode(response.body);
  
    token = json['token'].toString();
    log("token:$token");

    // get nearest trees
    var findTree = await http.get(Uri.parse(
      "https://services.arcgis.com/yeXpdyjk3azbqItW/arcgis/rest/services/TreeDatabase/FeatureServer/24/query?"
      "geometryType=esriGeometryPoint&distance=150&geometry=$currLongitude,$currLatitude&outFields=*&token=$token&f=json"
    ));

    json = jsonDecode(findTree.body);
    //log(json.toString());
  
    //render the marker
    renderMarker(json);

    setState(() {
      mapLoading = false;
    });
  }

  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List();
  }

  void renderMarker(dynamic json) {
    marker.clear();
    var i = 0;
    for (var point in json["features"]) {
      Tree tree = Tree.fromJson(point);

      marker.add(
        Marker(
          markerId: MarkerId(i.toString()),
          icon: mapMarker,
          position: LatLng(tree.latitude, tree.longitude),
          
          onTap: (){
            tree.editModeDebug();
            _displayPopup(context, tree, point);
          }
        )
      );

      //tree.toMapPoint(); // show the tree list
      i++;
    }

    // the current place marker
    marker.add(
      Marker(
        markerId: const MarkerId("curr"),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(currLatitude, currLongitude),
        
        onTap: () {
          //showHint(context, "You are here!");
          debugState("here");
        }
      )
    );
  }

  void _displayPopup(BuildContext context, Tree tree, dynamic json) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("ObjectID: ${tree.objectID}"),
          children: [
            Column(
              children: [
                Text("Longitude: ${tree.longitude}"),
                Text("Latitude: ${tree.latitude}"),
                Text("Common Name: ${tree.commonName}"),
                Text("Scientific Name: ${tree.scientificName}"),
                Text("Street: ${tree.streetName}"),
                Text("Suburb: ${tree.suburb}"),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: SimpleDialogOption(
                    onPressed: () {},
                    child: ElevatedButton(
                      child: const Text(
                        "Edit"
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        updateTree(tree);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: SimpleDialogOption(
                    onPressed: () {},
                    child: ElevatedButton(
                      child: const Text(
                        "View Detail"
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        //TODO: detail info from raw
                        debugState("detail");
                      },
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      }
    );
  }

  void updateTree(Tree tree) {
    log("edit");
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadTree(tree: tree,),
      )
    );
  }
}

class TreePointMap extends StatefulWidget {
  const TreePointMap({
    Key? key,
    required this.marker,
    required this.longitude, 
    required this.latitude
  }) : super(key: key);

  final Set<Marker> marker;
  final double longitude;  // x
  final double latitude; // y
  @override
  State<TreePointMap> createState() => _TreePointMapState();
}

class _TreePointMapState extends State<TreePointMap> {
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      rotateGesturesEnabled: false,
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.latitude, widget.longitude),
        zoom: 18,
        tilt: 0
      ),
      markers: widget.marker,
    );
  }
}