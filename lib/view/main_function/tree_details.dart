
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../provider/tree.dart';
import '../../reusable_widgets/reusable_methods.dart';

class TreeDetail extends StatefulWidget {
  const TreeDetail({ Key? key, required this.tree }) : super(key: key);

  final Tree tree;

  @override
  State<TreeDetail> createState() => _TreeDetailState();
}

class _TreeDetailState extends State<TreeDetail> {

  toDate(int time) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    String dateText = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(time));

    return dateText;
  }

  @override
  void initState() {
    widget.tree.treeInfoDebug();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Tree Details",
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: backgroundDecoration(
        context, 
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 120, 8, 0),
          child: Stack(
            children: [
              DataTable(
                dataRowHeight: 75,
                dataTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
                //columnSpacing: 10,
                headingTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                horizontalMargin: 15,
                showBottomBorder: true,
                dividerThickness: 3,
                columnSpacing: 40,
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
                rows: treeDataRows,
              ),
            ]
          ),
        ),
      )
    );
  }

  List<DataRow> get treeDataRows {
    return <DataRow>[
      treeRow('Object ID', widget.tree.objectID),
      treeRow("Version", widget.tree.version.toString()),
      treeRow('Asset ID', widget.tree.ASSNBRI),
      treeRow('Latitude', widget.tree.latitude.toStringAsFixed(6)),
      treeRow('Longitude', widget.tree.longitude.toStringAsFixed(6)),
      treeRow('Common Name', widget.tree.commonName),
      treeRow('Scientific Name', widget.tree.scientificName),
      treeRow('Short scientific Name', widget.tree.shortScientificName),
      treeRow('Long scientific Name', widget.tree.longScientificName),
      treeRow('Street Name', widget.tree.streetName),
      treeRow('Suburb', widget.tree.suburb),
      treeRow("Length", widget.tree.length.toString()),
      treeRow("Width", widget.tree.width.toString()),
      treeRow("Height", widget.tree.height.toString()),
      treeRow("Area", widget.tree.area.toStringAsFixed(3)),
      treeRow('BARCODE', widget.tree.BARCODE),
      treeRow('ASSET_STAT', widget.tree.ASSET_STAT),
      treeRow('DEPR_ASSET', widget.tree.DEPR_ASSET),
      treeRow('ACQN_DATEI', toDate(widget.tree.ACQN_DATEI)),
      treeRow('EXP_COMM_D', toDate(widget.tree.EXP_COMM_D)),
      treeRow('COMM_DATEI', toDate(widget.tree.COMM_DATEI)),
      treeRow('DISPOSAL_D', toDate(widget.tree.DISPOSAL_D)),
      treeRow('SUPP_METH', widget.tree.SUPP_METH),
      treeRow('SUPP_NAME', widget.tree.SUPP_NAME),
      treeRow('SUPP_REF', widget.tree.SUPP_REF),
      treeRow('MANUF_NAME', widget.tree.MANUF_NAME),
      treeRow('OTHER_NBR', widget.tree.OTHER_NBR),
      treeRow('CRUSER', widget.tree.CRUSER),
      treeRow('CRDATEI', toDate(widget.tree.CRDATEI)),
      treeRow('CRTIMEI', widget.tree.CRTIMEI),
      treeRow('CRTERM', widget.tree.CRTERM),
      treeRow('CRWINDOW', widget.tree.CRWINDOW),
      treeRow('LAST_MOD_U', widget.tree.LAST_MOD_U),
      treeRow('LAST_MOD_D', toDate(widget.tree.LAST_MOD_D)),
      treeRow('LAST_MOD_T', widget.tree.LAST_MOD_T),
      treeRow('LAST_MOD_1', widget.tree.LAST_MOD_1),
      treeRow('LAST_MOD_W', widget.tree.LAST_MOD_W),
      treeRow('ASSET_RID', widget.tree.ASSET_RID),
      treeRow('OPERATING_', widget.tree.OPERATING_),
      treeRow('PRIMARY_AT', widget.tree.PRIMARY_AT.toString()),
      treeRow('LAST_RPT_U', toDate(widget.tree.LAST_RPT_U)),
      treeRow('LAST_RPT_1', widget.tree.LAST_RPT_1),
      treeRow('ConstructM', widget.tree.ConstructM),
      treeRow('AssetSourc', widget.tree.AssetSourc),
      treeRow('WateringMe', widget.tree.WateringMe),
      treeRow('CapitalPro', widget.tree.CapitalPro),
      treeRow('Class_', widget.tree.Class_),
      treeRow('Category', widget.tree.Category),
      treeRow('Grp', widget.tree.Grp),
      treeRow('Facility', widget.tree.Facility),
      treeRow('Network', widget.tree.Network),
      treeRow('Team', widget.tree.Team),
      treeRow('CostCentre', widget.tree.CostCentre),
      treeRow('LCCLeases', widget.tree.LCCLeases),
      treeRow('MaintZoneC', widget.tree.MaintZoneC),
      treeRow('MaintZon_1', widget.tree.MaintZon_1),
      treeRow('condition', widget.tree.condition),
      treeRow('comment1', widget.tree.comment),
      treeRow('comment2', widget.tree.COMMENT2),
      treeRow('comment3', widget.tree.COMMENT3),
      treeRow('MaintCycle', widget.tree.MaintCycle),
      treeRow('create_us', widget.tree.create_us),
      treeRow('created_da', toDate(widget.tree.created_da)),
      treeRow('last_edite', widget.tree.last_edite),
      treeRow('last_edi_1', toDate(widget.tree.last_edi_1)),
    ];
  }

  DataRow treeRow(String attribute, String value) {
    return DataRow(
      cells: <DataCell>[
        DataCell(
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Text(attribute)
          )
        ),
        DataCell(
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.45,
            child: Text(value)
          )
        )
      ],
    );
  }
}
