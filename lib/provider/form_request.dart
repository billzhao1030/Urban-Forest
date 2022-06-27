// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';
import 'package:urban_forest/provider/tree.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';

class TreeRequest {
  // request type and attribute
  bool isAdd = true;
  int requestTime = 0;
  int requestLevel = 1;
  String requestEmail = "";
  String requestUID = "";
  bool confirmed = false;

  Tree tree = Tree();

  void toTable() {
    var str = "\nAdd request: ${isAdd.toString()}, By: $requestEmail\n"
    "Level: $requestLevel, Version: ${tree.version}, Request Time: $requestTime\n"
    "Location: x: ${tree.longitude}, y: ${tree.latitude}\n"
    "Scientific: ${tree.scientificName}, Common: ${tree.commonName}, Short: ${tree.shortScientificName}\n"
    "Long: ${tree.longScientificName}\n"
    "Street: ${tree.streetName}, Suburb: ${tree.suburb}\n"
    "Class: ${tree.locClass}, Category: ${tree.locCategory}, Type: ${tree.locType}\n"
    "Height: ${tree.height}, Length: ${tree.length}, Width: ${tree.width}, Area: ${tree.area}\n"
    "Condition: ${tree.condition}\n"
    "Comment: ${tree.comment}\n"
    "Asset ID: ${tree.ASSNBRI}\n"
    "Relavant date: ${tree.COMM_DATEI}, ${tree.CRDATEI}, ${tree.LAST_MOD_D}, ${tree.LAST_RPT_U}\n"
    "Last_edite: ${tree.last_edite}";

    debugState(str);
  }

  uploadFirebase() async {
    DateFormat dateFormatID = DateFormat("yyyyMMddHHmmss");
    var addID = dateFormatID.format(DateTime.now()) + "%$requestUID";

    var data = {
      'isAdd': isAdd,
      'requestTime': requestTime,
      'requestLevel': requestLevel,
      'requestEmail': requestEmail,
      'requestUID': requestUID,
      'confirmed': confirmed,
      'version': tree.version,
      'scientificName': tree.scientificName,
      'shortScientificName': tree.shortScientificName,
      'commonName': tree.commonName,
      'longScientificName': tree.longScientificName,
      'latitude': tree.latitude,
      'longtitude': tree.longitude,
      'suburb': tree.suburb,
      'streetName': tree.streetName,
      'locClass': tree.locClass,
      'locCategory': tree.locCategory,
      'locType': tree.locType,
      'comment': tree.comment,
      'condition': tree.condition,
      'height': tree.height,
      'length': tree.length,
      'width': tree.width,
      'area': tree.area,
      'ASSNBRI': tree.ASSNBRI,
      'creat_us': tree.create_us,
      'created_da': tree.created_da,
      'last_edite': tree.last_edite,
      'last_edi_1': tree.last_edi_1,
      'BARCODE': tree.BARCODE,
      'ASSET_STAT': tree.ASSET_STAT,
      'DEPR_ASSET': tree.DEPR_ASSET,
      'ACQN_DATEI': tree.ACQN_DATEI,
      'EXP_COMM_D': tree.EXP_COMM_D,
      'COMM_DATEI': tree.COMM_DATEI,
      'DISPOSAL_D': tree.DISPOSAL_D,
      'SUPP_METH': tree.SUPP_METH,
      'SUPP_NAME': tree.SUPP_NAME,
      'SUPP_REF': tree.SUPP_REF,
      'COMMENT1': tree.COMMENT1,
      'COMMENT2': tree.COMMENT2,
      'COMMENT3': tree.COMMENT3,
      'MANUF_NAME': tree.MANUF_NAME,
      'OTHER_NBR': tree.OTHER_NBR,
      'CRUSER': tree.CRUSER,
      'CRDATEI': tree.CRDATEI,
      'CRTIMEI': tree.CRTIMEI,
      'CRTERM': tree.CRTERM,
      'CRWINDOW': tree.CRWINDOW,
      'LAST_MOD_U': tree.LAST_MOD_U,
      'LAST_MOD_D': tree.LAST_MOD_D,
      'LAST_MOD_T': tree.LAST_MOD_T,
      'LAST_MOD_1': tree.LAST_MOD_1,
      'LAST_MOD_W': tree.LAST_MOD_W,
      'ASSET_RID': tree.ASSET_RID,
      'OPERATING_': tree.OPERATING_,
      'PRIMARY_AT': tree.PRIMARY_AT,
      'GIS_ID': tree.GIS_ID,
      'LAST_RPT_U': tree.LAST_RPT_U,
      'LAST_RPT_1': tree.LAST_RPT_1,
      'ConstructM': tree.ConstructM,
      'AssetSourc': tree.AssetSourc,
      'WateringMe': tree.WateringMe,
      'CapitalPro': tree.CapitalPro,
      'Class_': tree.Class_,
      'Category': tree.Category,
      'Grp': tree.Grp,
      'Facility': tree.Facility,
      'Network': tree.Network,
      'Team': tree.Team,
      'CostCentre': tree.CostCentre,
      'LCCLeases': tree.LCCLeases,
      'MaintZoneC': tree.MaintZoneC,
      'MaintZon_1': tree.MaintZon_1,
      'MaintCycle': tree.MaintCycle,
      'GlobalID': tree.GlobalID,
    };


    dbRequests.doc(addID)
      .set(data)
      .then((value) => debugState("added!"))
      .catchError((error) {
        debugState(error.toString());
      });
  }
}