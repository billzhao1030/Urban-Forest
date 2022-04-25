import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/debug_format.dart';

import 'package:geolocator/geolocator.dart';

class AddTree extends StatefulWidget {
  const AddTree({ Key? key }) : super(key: key);

  @override
  State<AddTree> createState() => _AddTreeState();
}

class _AddTreeState extends State<AddTree> {
  TextEditingController _passwordTextController = TextEditingController();
  Position? position;

  Future<void> getLocation() async {
    setState(() async {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      //print(position?.latitude);
      //print(position?.longitude);
    }); 
  }

  @override
  void initState() {
    super.initState();

    //getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return backgroundDecoration(
      context, 
      Padding(
        padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height * 0.08, 20, 0),
        child: Center(
          child: Column(
            children: [
              formText("Add a tree"),
              FutureBuilder(
                future: getLocation(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Container(color: Colors.amber,);
                  }

                  if (snapshot.connectionState == ConnectionState.done) {
                    return locationField();
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      )
    );
  }

  DefaultTextStyle formText(String text, {double fontsize = 24, FontStyle fontStyle = FontStyle.normal}) {
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: fontsize,
        fontWeight: FontWeight.bold,
        fontStyle: fontStyle
      ),
      child: Text(text),
    );
  }

  Widget locationField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        formText("${position?.latitude}"),
        formText("${position?.longitude}"),
      ],
    );
  }
}