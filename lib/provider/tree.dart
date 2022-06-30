// ignore_for_file: non_constant_identifier_names

import 'package:urban_forest/utils/debug_format.dart';

class Tree {
  // version
  int version = 1; // VERS
  String objectID = "";

  // species
  String scientificName = ""; // DESCR
  String shortScientificName = ""; // SHORT_DESC
  String commonName = ""; // SEARCH_DES
  String get longScientificName { // LONG_DESCR
    return "$commonName $shortScientificName $scientificName";
  }

  // location
  double latitude = 0;
  double longitude = 0;

  String suburb = ""; // Suburb
  String streetName = ""; // LocGrp

  String? locClass = ""; // LocClass
  String? locCategory = ""; // LocCat
  String locType = ""; // TreeLocati: STREET/PARK

  // condition
  String comment = ""; // Comment 1
  String condition = "Not Applicable"; // Condition

  // scale
  double height = 0; // LengthDime
  double length = 0; // WidthDimen
  double width = 0; // HeightDime
  double get area { // AreaDimens
    return length * width;
  }

  // inner attributes
  String ASSNBRI = ""; // GIS ID
  String create_us = "Andrew.Ritchie@launceston.tas.gov.au_launceston";
  int created_da = 0; // DATE
  String last_edite = "Andrew.Ritchie@launceston.tas.gov.au_launceston";
  int last_edi_1 = 0; // DATE


  // default attributes
  String BARCODE = "";
  String ASSET_STAT = "N";
  String DEPR_ASSET = "N";

  int ACQN_DATEI = 0; // DATE
  int EXP_COMM_D = 0; // DATE
  int COMM_DATEI = 0; // DATE
  int DISPOSAL_D = 0; // DATE

  String SUPP_METH = "NA";
  String SUPP_NAME = "";
  String SUPP_REF = "";
  String get COMMENT1 { return comment;}
  String COMMENT2 = "";
  String COMMENT3 = "";
  String MANUF_NAME = "";
  String OTHER_NBR = "";

  String CRUSER = "ORDERSR";
  int CRDATEI = 0; // DATE
  String CRTIMEI = "140944";
  String CRTERM = "PC380306";
  String CRWINDOW = "F1ASR090";

  String LAST_MOD_U = "ORDERSR";
  int LAST_MOD_D = 0; // DATE
  String LAST_MOD_T = "102957";
  String LAST_MOD_1 = "PC380306";
  String LAST_MOD_W = "F1ASR090";

  String ASSET_RID = "";
  String OPERATING_ = "O";
  int PRIMARY_AT = 0;
  String get GIS_ID { return ASSNBRI; }

  int LAST_RPT_U = 0; // DATE
  String LAST_RPT_1 = "220340";
  String ConstructM = "NA";
  String AssetSourc = "NA";
  String WateringMe = "NOTRECOR";
  String CapitalPro = "";

  String Class_ = "Facilities"; // Class
  String Category = "Trees";
  String Grp = "Tree";
  String Facility = "Not Applicable";

  String Network = "Infrastructure & Assets";
  String Team = "IAN Parks & Sustainability";
  String CostCentre = "IAN Recreation & Parks";
  String LCCLeases = "Not Subject to a Lease";
  String MaintZoneC = "Not Applicable";
  String MaintZon_1 = "Not Applicable";
  String MaintCycle = "Not Applicable";

  String GlobalID = "";

  Tree();

  Tree.fromJson(Map<String, dynamic> json) 
  :
    latitude = json["geometry"]["y"],
    longitude = json["geometry"]["x"]
    {
      var attributes = json["attributes"];
      
      objectID = attributes["OBJECTID"].toString();
      streetName = attributes["LocGrp"].toString();
      suburb = attributes["Suburb"].toString();

      commonName = attributes["SEARCH_DES"].toString().toLowerCase();
      scientificName = attributes["DESCR"].toString();

      version = attributes["VERS"];
      ASSNBRI = attributes["ASSNBRI"];

      locType = attributes["TreeLocati"].toString();
      locClass = attributes["LocClass"].toString();
      locCategory = attributes["LocCat"].toString();

      length = attributes["LengthDime"].toDouble();
      width = attributes["WidthDimen"].toDouble();
      height = attributes["HeightDime"].toDouble();

      shortScientificName = attributes["SHORT_DESC"];
      BARCODE = attributes["BARCODE"];
      ASSET_STAT = attributes["ASSET_STAT"];
      DEPR_ASSET = attributes["DEPR_ASSET"];
      ACQN_DATEI = attributes["ACQN_DATEI"] as int;
      EXP_COMM_D = attributes["EXP_COMM_D"] as int;
      COMM_DATEI = attributes["COMM_DATEI"] as int;
      DISPOSAL_D = attributes["DISPOSAL_D"] as int;
      SUPP_METH = attributes["SUPP_METH_"];
      SUPP_NAME = attributes["SUPP_NAME"];
      SUPP_REF = attributes["SUPP_REF"];
      MANUF_NAME = attributes["MANUF_NAME"];
      OTHER_NBR = attributes["OTHER_NBR"];
      CRUSER = attributes["CRUSER"];
      CRDATEI = attributes["CRDATEI"] as int;
      CRTIMEI = attributes["CRTIMEI"].toString();
      CRTERM = attributes["CRTERM"];
      CRWINDOW = attributes["CRWINDOW"];
      LAST_MOD_U = attributes["LAST_MOD_U"];
      LAST_MOD_D = attributes["LAST_MOD_D"];
      LAST_MOD_T = attributes["LAST_MOD_T"].toString();
      LAST_MOD_1 = attributes["LAST_MOD_1"];
      LAST_MOD_W = attributes["LAST_MOD_W"];
      ASSET_RID = attributes["ASSET_RID"].toString();
      OPERATING_ = attributes["OPERATING_"];
      PRIMARY_AT = attributes["PRIMARY_AT"];
      LAST_RPT_U = attributes["LAST_RPT_U"];
      LAST_RPT_1 = attributes["LAST_RPT_1"].toString();
      ConstructM = attributes["ConstructM"];
      AssetSourc = attributes["AssetSourc"];
      WateringMe = attributes["WateringMe"];
      CapitalPro = attributes["CapitalPro"];
      Class_ = attributes["Class"];
      Category = attributes["Category"];
      Grp = attributes["Grp"];
      Facility = attributes["Facility"];
      Network = attributes["Network"];
      Team = attributes["Team"];
      CostCentre = attributes["CostCentre"];
      LCCLeases = attributes["LCCLeases"];
      MaintZoneC = attributes["MaintZoneC"];
      MaintZon_1 = attributes["MaintZon_1"];
      condition = attributes["Condition"];
      MaintCycle = attributes["MaintCycle"];
      create_us = attributes["created_us"];
      created_da = attributes["created_da"];
      last_edite = attributes["last_edite"];
      last_edi_1 = attributes["last_edi_1"];
    }


  
  void treeInfoDebug() {
    var str = "Object ID: $objectID, ASSNBRI: $ASSNBRI, Version: $version\n"
    "x: $longitude, y: $latitude\n"
    "Common: $commonName, Scientific: $scientificName, Short Scientific\n"
    "Street: $streetName, Suburb: $suburb\n"
    "Width: $width, Length: $length, Height: $height\n"
    "LocClass: $locClass, LocCategory: $locCategory, LocType: $locType\n"
    "barcode: $BARCODE, ";

    debugState(str);
  }  

  
}