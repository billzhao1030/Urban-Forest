import 'package:flutter/cupertino.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';

class TreeMap extends StatefulWidget {
  const TreeMap({ Key? key }) : super(key: key);

  @override
  State<TreeMap> createState() => _TreeMapState();
}

class _TreeMapState extends State<TreeMap> {
  @override
  Widget build(BuildContext context) {
    return backgroundDecoration(
      context, 
      Container()
    );
  }
}