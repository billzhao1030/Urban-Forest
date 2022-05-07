
import 'package:flutter/material.dart';

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
      body: const Text("asfhkahf"),
    );
  }
}