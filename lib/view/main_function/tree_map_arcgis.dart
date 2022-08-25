// ignore_for_file: await_only_futures

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:urban_forest/provider/account_provider.dart';
import 'package:urban_forest/provider/tree.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/main_function/tree_details.dart';
import 'package:urban_forest/view/main_function/upload_tree.dart';


class TreeMap extends StatefulWidget {
  const TreeMap({ Key? key, required this.controller, required this.model}) : super(key: key);

  final AccountModel model;

  final CupertinoTabController controller;

  @override
  State<TreeMap> createState() => _TreeMapState();
}

class _TreeMapState extends State<TreeMap> {
  var marker = <Marker>{};
  var groupCircle = <Circle>{};
  var token = ""; // for map access

  bool mapHybrid = false;

  var mapLoading = true;

  double searchLatitude = 0;
  double searchLongitude = 0;

  late BitmapDescriptor mapMarker;
  bool addPin = false;

  @override
  void initState() {
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
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: mapLoading 
                    ? const Center(child: CircularProgressIndicator(),)
                    : GoogleMap(
                      myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      mapToolbarEnabled: false,
                      mapType: mapHybrid ? MapType.hybrid : MapType.normal,
                      rotateGesturesEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(searchLatitude, searchLongitude),
                        zoom: 18,
                        tilt: 0
                      ),
                      markers: marker,
                      circles: groupCircle,
                      onLongPress: (LatLng location) {
                        setState(() {
                          const MarkerId markerId = MarkerId("RANDOM_ID");
                          Marker newMarker = Marker(
                            markerId: markerId,
                            draggable: true,
                            position: location, 
                            icon: BitmapDescriptor.defaultMarker,
                            onTap: () {
                              longPressPointDialog(context, location);
                            }
                          );
                          
                          if (addPin) {
                            marker.remove(marker.last);
                          }

                          marker.add(newMarker);
                          addPin = true;
                        });
                      }
                    )
                ),
              ],
            ),
            Positioned(
              child: Transform.scale(
                scale: 0.75,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.23,
                  child: SliderSettingsTile(
                    title: 'Tree group radius (metres)',
                    settingKey: 'key-distance-map',
                    defaultValue: 100,
                    min: 25,
                    max: 250,
                    step: 5,
                    leading: const Icon(Icons.social_distance),
                    onChange: (value) {
                      debugPrint('key-distance-map: $value');
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Row(
            children: [
              FloatingActionButton(
                heroTag: "refresh",
                child: const Icon(Icons.refresh),
                onPressed: (){
                  setState(() {
                    mapLoading = true;
                  });
                  dataLoading();
                },
              ),
              const SizedBox(width: 8,),
              FloatingActionButton(
                heroTag: "mapType",
                child: const Icon(Icons.map),
                backgroundColor: mapHybrid ? Colors.green : Colors.grey,
                onPressed: (){
                  setState(() {
                    mapHybrid = !mapHybrid;
                  });
                },
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
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

    return await Geolocator.getCurrentPosition(forceAndroidLocationManager: true);
  }

  void setMarker() async {
    Uint8List? markerIcon = await getBytesFromAsset('assets/images/tree.png', 90);
    mapMarker = await BitmapDescriptor.fromBytes(markerIcon!);
  }

  // refetch all trees
  dataLoading({LatLng? search}) async {
    // get location
    Position position;
    if (search == null) {
      position = await _determinePosition();
      searchLatitude = position.latitude;
      searchLongitude = position.longitude;
    } else {
      searchLatitude = search.latitude;
      searchLongitude = search.longitude;
    }

    groupCircle = {
      Circle(
        circleId: const CircleId("group"),
        center: LatLng(searchLatitude, searchLongitude),
        radius: Settings.getValue('key-distance-map', defaultValue: 100)!,
        strokeColor: Colors.black54,
        strokeWidth: 3
      ),
    };

    // get token for oAuth
    token = "";
    final response = await http.get(Uri.parse(
      "https://www.arcgis.com/sharing/generateToken?username=xunyiz@utas.edu.au&password=$tokenPass&referer=launceston.maps.arcgis.com&f=json"
    ));
    var json = jsonDecode(response.body);
  
    token = json['token'].toString();
    log("token:$token");

    double distance = 100;

    if (globalLevel > 1) {
      distance = Settings.getValue('key-distance-map', defaultValue: 100)!;
    }
    // get nearest trees
    var findTree = await http.get(Uri.parse(
      "https://services.arcgis.com/yeXpdyjk3azbqItW/arcgis/rest/services/TreeDatabase/FeatureServer/24/query?"
      "geometryType=esriGeometryPoint&distance=$distance&geometry=$searchLongitude,$searchLatitude&outFields=*&token=$token&f=json"
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
            tree.treeInfoDebug();
            debugState(point.toString());

            _displayPopup(context, tree);
          }
        )
      );

      //tree.treeInfoDebug(); // show the tree list
      i++;
    }
  }

  void longPressPointDialog(BuildContext context, LatLng location) {
    TextStyle locationStyle = const TextStyle(
      fontSize: 18,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w600
    );

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("Location", style: TextStyle(fontSize: 24, fontWeight:FontWeight.bold)),
          children: [
            const SizedBox(height: 12,),
            Text(
              "Latitude: ${location.latitude.toStringAsFixed(6)}",
              textAlign: TextAlign.center,
              style: locationStyle,
            ),
            Text(
              "Longitude: ${location.longitude.toStringAsFixed(6)}",
              textAlign: TextAlign.center,
              style: locationStyle,
            ),
            const SizedBox(height: 12,),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: SimpleDialogOption(
                child: ElevatedButton(
                  child: const Text(
                    "Add from here",
                    style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    addTreeFromMap(location);
                  },
                ),
              ),
            ),

            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: SimpleDialogOption(
                child: ElevatedButton(
                  child: const Text(
                    "Search trees",
                    style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      mapLoading = true;
                    });
                    dataLoading(search: location);
                  },
                ),
              ),
            ),
          ],
        );
      }
    );
  }

  void _displayPopup(BuildContext context, Tree tree) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("ObjectID: ${tree.objectID}"),
          children: [
            Column(
              children: [
                DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Attributes',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Value',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: <DataRow>[
                    DataRow(
                      cells: <DataCell>[
                        const DataCell(Text('Latitude')),
                        DataCell(Text(tree.latitude.toStringAsFixed(6))),
                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        const DataCell(Text('Longitude')),
                        DataCell(Text(tree.longitude.toStringAsFixed(6))),
                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        const DataCell(Text('Common Name')),
                        DataCell(Text(tree.commonName)),
                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        const DataCell(Text('Scientific Name')),
                        DataCell(Text(tree.scientificName)),
                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        const DataCell(Text('Street Name')),
                        DataCell(Text(tree.streetName)),
                      ],
                    ),
                    DataRow(
                      cells: <DataCell>[
                        const DataCell(Text('Suburb')),
                        DataCell(Text(tree.suburb)),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: SimpleDialogOption(
                    onPressed: () {},
                    child: ElevatedButton(
                      child: const Text(
                        "Edit",
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        updateTree(tree);
                      },
                    ),
                  ),
                ),
                (globalLevel > 1) ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: SimpleDialogOption(
                    onPressed: () {},
                    child: ElevatedButton(
                      child: const Text(
                        "View Detail",
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TreeDetail(tree: tree),
                          )
                        );
                      },
                    ),
                  ),
                ) : Container()
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
        builder: (context) => UploadTree(tree: tree, model: widget.model,),
      )
    );
  }

  void addTreeFromMap(LatLng location) {
    log("add from map");
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploadTree(preLocation: location, model: widget.model,),
      )
    );
  }
}