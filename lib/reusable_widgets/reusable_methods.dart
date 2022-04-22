import 'package:flutter/material.dart';
import 'package:urban_forest/reusable_widgets/reusable_wiget.dart';

// show the snack bar message
void showHint(BuildContext context, String message, {bool verify = false}) {
  ScaffoldMessenger.of(context).showSnackBar(snackBarHint(message, verify: verify, context: context));
}