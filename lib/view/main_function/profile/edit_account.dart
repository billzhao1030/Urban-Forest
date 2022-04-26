import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/provider/user.dart';

class EditAccount extends StatefulWidget {
  const EditAccount({ Key? key, required this.userUID }) : super(key: key);
  final userUID;

  @override
  State<EditAccount> createState() => _EditAccountState();
}

class _EditAccountState extends State<EditAccount> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Text("asfhkahf"),
      ),
    );
  }
}