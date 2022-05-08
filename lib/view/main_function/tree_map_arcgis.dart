import 'dart:convert';
import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:urban_forest/provider/tree.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/debug_format.dart';

class TreeMap extends StatefulWidget {
  const TreeMap({ Key? key }) : super(key: key);

  @override
  State<TreeMap> createState() => _TreeMapState();
}

class _TreeMapState extends State<TreeMap> {
  var marker = Set<Marker>();
  var token = ""; // for map access

  var mapLoading = true;

  double currLatitude = 0;
  double currLongtitude = 0;

  @override
  void initState() {
    //debugState("access level: $globalLevel");
    dataLoading();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: mapLoading 
              ? const Center(child: CircularProgressIndicator(),)
              : TreePointMap(marker: marker, longtitude: currLongtitude, latitude: currLatitude,),
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

  dataLoading() async {
    // get location
    Position position = await _determinePosition();
    currLatitude = position.latitude;
    currLongtitude = position.longitude;
    debugState("latitude: ${currLatitude.toStringAsFixed(6)}");
    debugState("longtitude: ${currLongtitude.toStringAsFixed(6)}");

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
      "geometryType=esriGeometryPoint&distance=200&geometry=$currLongtitude,$currLatitude&outFields=*&token=$token&f=json"
    ));

    json = jsonDecode(findTree.body);
    log(json.toString());
  
    //render the marker
    renderMarker(json);

    setState(() {
      mapLoading = false;
    });
  }

  void renderMarker(dynamic json) {
    marker.clear();
    var i = 0;
    for (var point in json["features"]) {
      var x = point["geometry"]["x"];
      var y = point["geometry"]["y"];
      var version = point["attributes"]["VERS"];

      Tree tree = Tree();

      marker.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(y,x),
          onTap: (){
            log("Location: x=>$x, y:$y");
            log("Version: $version");
            _displayPopup(context, tree);
          }
        )
      );
    }
  }

  // display the popup menu after click the tree point
  void _displayPopup(BuildContext context, Tree tree) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("11"),
          children: [
            Column(
              children: [
                SimpleDialogOption(
                  onPressed: () {},
                  child: ElevatedButton(
                    child: const Text(
                      "Edit"
                    ),
                    onPressed: () {
                      log("edit");
                      updateTree();
                    },
                  ),
                )
              ],
            ),
          ],
        );
      }
    );
  }

  void updateTree() {

  }
}

class TreePointMap extends StatefulWidget {
  const TreePointMap({
    Key? key,
    required this.marker,
    required this.longtitude, 
    required this.latitude
  }) : super(key: key);

  final Set<Marker> marker;
  final double longtitude;  // x
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
        target: LatLng(widget.latitude, widget.longtitude),
        zoom: 17,
        tilt: 0
      ),
      markers: widget.marker,
    );
  }
}