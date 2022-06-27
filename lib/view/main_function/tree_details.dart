import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:urban_forest/utils/debug_format.dart';

import '../../reusable_widgets/reusable_methods.dart';

class TreeDetail extends StatefulWidget {
  const TreeDetail({ Key? key, required this.json }) : super(key: key);

  final Map<String, dynamic> json;

  @override
  State<TreeDetail> createState() => _TreeDetailState();
}

class _TreeDetailState extends State<TreeDetail> {
  @override
  void initState() {

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
          "Sign Up",
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: backgroundDecoration(
        context, 
        Container()
      )
    );
  }
}