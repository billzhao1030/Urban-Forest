import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class locationTemp extends StatefulWidget {
  const locationTemp({ Key? key }) : super(key: key);

  @override
  State<locationTemp> createState() => _locationTempState();
}

class _locationTempState extends State<locationTemp> {
  Position? position;

  void getLocation() async {
    setState(() async {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      print(position?.latitude);
      print(position?.longitude);
    }); 
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                block(Colors.blue),
                block(Colors.amber),
                block(Colors.blue),
                block(Colors.amber),
                block(Colors.blue),
                block(Colors.amber),
              ],
            ),
          )
        ),
      ),
    );
  }

  SizedBox block(Color boxColor) {
    return SizedBox(
              height: 190,
              child: Container(color: boxColor),
            );
  }
}