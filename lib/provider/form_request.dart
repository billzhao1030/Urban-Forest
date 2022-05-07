// ignore_for_file: non_constant_identifier_names

class TreeRequest {
  // request type and attribute
  bool isAdd = true;
  String requestTime = "";
  int requestLevel = 1;
  String requestEmail = "";

  // species
  String? scientifiName;
  String? longScientifiName;
  String? shortScientificName;
  String? commonName;

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
  String ASSNBRI = "";

  // default attributes
  String BARCODE = "";
  String ASSET_STAT = "N";
  String DEPR_ASSET = "N";
  String ACQN_DATEI = "";
  String EXP_COMM_D = "";
  String DISPOSAL_D = "";

  String SUPP_METH = "NA";
  String SUPP_NAME = "";
  String SUPP_REF = "";
  String COMMENT1 = "";
  String COMMENT2 = "";
  String COMMENT3 = "";

  
}