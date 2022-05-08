// ignore_for_file: non_constant_identifier_names

import 'package:flutter_map/flutter_map.dart';
import 'package:urban_forest/provider/tree.dart';
import 'package:urban_forest/utils/debug_format.dart';

class TreeRequest {
  // request type and attribute
  bool isAdd = true;
  String requestTime = "";
  int requestLevel = 1;
  String requestEmail = "";

  Tree tree = Tree();

  void toTable() {
    var str = "\nAdd request: ${isAdd.toString()}, By: $requestEmail\n"
    "Level:$requestLevel, Version: ${tree.version}, Request Time: $requestTime\n"
    "Location: x:${tree.longtitude}, y: ${tree.latitude}\n"
    "Scientific: ${tree.scientificName}, Common: ${tree.commonName}, Short: ${tree.shortScientificName}\n"
    "Long: ${tree.longScientificName}\n"
    "Street: ${tree.streetName}, Suburb: ${tree.suburb}\n"
    "Class: ${tree.locClass}, Category: ${tree.locCategory}, Type: ${tree.locType}\n"
    "Height: ${tree.height}, Length: ${tree.length}, Width: ${tree.width}, Area: ${tree.area}\n"
    "Condition: ${tree.condition}\n"
    "Comment: ${tree.comment}\n"
    "Asset ID: ${tree.ASSNBRI}";

    debugState(str);
  }
}