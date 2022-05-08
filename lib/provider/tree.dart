// ignore_for_file: non_constant_identifier_names

class Tree {
  // version
  int version = 1; // VERS

  // species
  String scientificName = ""; // DESCR
  String shortScientificName = ""; // SHORT_DESC
  String commonName = ""; // SEARCH_DES
  String get longScientificName { // LONG_DESCR
    return "$commonName $shortScientificName $scientificName";
  }

  // location
  double latitude = 0;
  double longtitude = 0;

  String suburb = ""; // Suburb
  String streetName = ""; // LocGrp

  String locClass = ""; // LocClass
  String locCategory = ""; // LocCat
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
  String creat_us = "Andrew.Ritchie@launceston.tas.gov.au_launceston";
  String created_da = ""; // DATE
  String last_edite = "Andrew.Ritchie@launceston.tas.gov.au_launceston";
  String last_edi_1 = ""; // DATE
  

  // default attributes
  String BARCODE = "";
  String ASSET_STAT = "N";
  String DEPR_ASSET = "N";

  String ACQN_DATEI = ""; // DATE
  String EXP_COMM_D = ""; // DATE
  String COMM_DATEI = ""; // DATE
  String DISPOSAL_D = ""; // DATE

  String SUPP_METH = "NA";
  String SUPP_NAME = "";
  String SUPP_REF = "";
  String get COMMENT1 { return comment;}
  String COMMENT2 = "";
  String COMMENT3 = "";
  String MANUF_NAME = "";
  String OTHER_NBR = "";

  String CRUSER = "ORDERSR";
  String CRDATEI = ""; // DATE
  String CRTIMEI = "140944";
  String CRTERM = "PC380306";
  String CRWINDOW = "F1ASR090";

  String LAST_MOD_U = "ORDERSR";
  String LAST_MOD_D = ""; // DATE
  String LAST_MOD_T = "";
  String LAST_MOD_1 = "PC380306";
  String LAST_MOD_W = "F1ASR090";

  String ASSET_RID = "";
  String OPERATING_ = "O";
  int PRIMARY_AT = 0;
  String get GIS_ID { return ASSNBRI; }

  String LAST_RPT_U = ""; // DATE
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
}