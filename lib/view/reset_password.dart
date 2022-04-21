import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/main.dart';
import 'package:urban_forest/utils/debug_format.dart';

import '../reusable_widgets/reusable_wiget.dart';
import '../utils/color_utils.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({ Key? key }) : super(key: key);

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _emailTextController = TextEditingController();

  final String successSend = "We have sent the password reset email\nYou can close this window safely now";
  bool isSend = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Reset Password",
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor(backgroundColorArray[0]),
              hexStringToColor(backgroundColorArray[1]),
              hexStringToColor(backgroundColorArray[2])
            ], 
            begin: Alignment.topCenter, 
            end: Alignment.bottomCenter
          )
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                
                FormTextBox(
                  labelText: "Enter Email", 
                  icon: Icons.person_outline,
                  isUserName: false,
                  isPasswordType: false,
                  controller: _emailTextController,
                ),
                const SizedBox(
                  height: 20,
                ),
                
                firebaseButton(context, "Reset", () {
                  FirebaseAuth.instance
                    .sendPasswordResetEmail(email: _emailTextController.text.trim())
                    .then((value) {
                      setState(() {
                        isSend = true;
                      });
                    })
                    .onError((error, stackTrace) {
                      debugState("Error: ${error.toString()}");
                  });
                }),
                
                isSend ? Text(
                  successSend,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontStyle: FontStyle.italic
                  ),
                ) : Container()
              ],
            ),
          )
        )
      ),
    );
  } 
}
