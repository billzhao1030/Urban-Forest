import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TreeMap extends StatefulWidget {
  const TreeMap({ Key? key }) : super(key: key);

  @override
  State<TreeMap> createState() => _TreeMapState();
}

class _TreeMapState extends State<TreeMap> {
  var marker = <Marker>[];
  var token = ""; // for map access

  var mapLoading = true;

  @override
  void initState() {
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return mapLoading ? Center(child: CircularProgressIndicator(),)
    : treeMap(marker: marker);
  }

  getToken() async {
    token = "";
    final response = await http.get(Uri.parse(
      "https://www.arcgis.com/sharing/generateToken?username=xunyiz@utas.edu.au&password=dayi87327285&referer=launceston.maps.arcgis.com&f=json"
    ));
    //await Future.delayed(Duration(seconds: 2));
    var json = jsonDecode(response.body);
  
    
    token = json['token'].toString();
    //log("token:$token");

    final r2 = await http.get(Uri.parse(
      "https://services.arcgis.com/yeXpdyjk3azbqItW/arcgis/rest/services/TreeDatabase/FeatureServer/0/addFeatures?token=$token&f=json"
    ));

    var j = jsonDecode(r2.body);
    log(j.toString());

    // Map<String, dynamic> body = {
    //   "geometry": {
    //     "x":-41.4005,
    //     "y":147.1379
    //   },
    //   "attributes": {
    //     "VERS":1,
    //     "ASSNBRI":109111
    //   }
    // };

    // var list = [];
    // list.add(body);

    // var q = http.MultipartRequest("POST", Uri.parse(
    //   "https://services.arcgis.com/yeXpdyjk3azbqItW/arcgis/rest/services/TreeDatabase/FeatureServer/0/addFeatures?token=$token&f=json"
    //   ));

    // q.fields['features'] = jsonEncode(list);
    // var r = await q.send();

    // var str = await http.Response.fromStream(r);
    // log(str.body);

    
    //-41.4005, 147.1378
    marker.add(
      Marker(point: LatLng(-41.4005, 147.1378), builder: (ctx) => Icon(Icons.pin_drop))
    );
    marker.add(
      Marker(point: LatLng(-41.43, 147.1), builder: (ctx) => Icon(Icons.pin_drop)),
    );

    setState(() {
      mapLoading = false;
    });
  }
}

class treeMap extends StatelessWidget {
  const treeMap({
    Key? key,
    required this.marker,
  }) : super(key: key);

  final List<Marker> marker;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(-41.4, 147.1),
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          // attributionBuilder: (_) {
          //   return Text("© OpenStreetMap contributors");
          // },
        ),
        MarkerLayerOptions(
          markers: marker
        ),
      ],
    );
  }
}