class TreeRequest {
  // species
  String? scientifiName;
  String? longScientifiName;
  String? shortScientificName;

  // location
  double latitude = 0;
  double longtitude = 0;

  String? suburb;
  String? streetName;

  // condition
  String comment = "";
  bool condition = true;

  int version = 1;

  // scale
  double height = 0;
  double length = 0;
  double width = 0;
  double area = 0;

  // inner attributes
  String assetID = "";

  // default attributes

}