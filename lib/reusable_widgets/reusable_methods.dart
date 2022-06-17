import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:urban_forest/reusable_widgets/reusable_wiget.dart';

import '../utils/color_utils.dart';
import '../utils/reference.dart';

// show the snack bar message
void showHint(BuildContext context, String message, {bool verify = false, double b = 12}) {
  ScaffoldMessenger.of(context).showSnackBar(snackBarHint(message, verify: verify, context: context, b: b));
}

// background for most of screen
Container backgroundDecoration(BuildContext context, Widget? child) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          hexStringToColor(backgroundColorArray[0]),
          hexStringToColor(backgroundColorArray[1]),
          hexStringToColor(backgroundColorArray[2]),
        ], 
        begin: Alignment.topCenter, 
        end: Alignment.bottomCenter
      )
    ),
    child: Scrollbar(
      isAlwaysShown: false,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        scrollDirection: Axis.vertical,
        child: child
      ),
    ),
  );
}

void showError(BuildContext context, String message, double paddingBottom) {
  try {
    ScaffoldMessenger.of(context).showSnackBar(snackBarHint(message, b: paddingBottom));
  } catch(e) {
    log(e.toString());
  }
}

// the form text in cupertino
DefaultTextStyle formText(String text, {
  double fontsize = 20, 
  FontStyle fontStyle = FontStyle.normal,
  Color fontColor = Colors.white
  }) {
  return DefaultTextStyle(
    textAlign: TextAlign.center,
    style: TextStyle(
      color: fontColor,
      fontSize: fontsize,
      fontWeight: FontWeight.bold,
      fontStyle: fontStyle,
    ),
    child: Text(text),
  );
}