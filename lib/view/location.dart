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
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            
          ],
        )
      ),
    );
  }
}