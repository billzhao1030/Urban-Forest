import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/view/account/sign_in.dart';

import '../../utils/color_utils.dart';
import '../../utils/debug_format.dart';
import '../../utils/reference.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({ 
    Key? key, 
    required this.firstName, 
    required this.lastName, 
    required this.userName 
  }) : super(key: key);

  final String firstName;
  final String lastName;
  final String userName;

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  Timer? timer;
  bool isEmailVerified = false;
  bool canResendEmail = false;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    debugState(FirebaseAuth.instance.currentUser!.uid);

    var user = FirebaseAuth.instance.currentUser!;
    var uid = user.uid;
    var email = user.email;

    dbUser.doc(uid).set({
      'uid': uid,
      'email': email,
      'firstName': widget.firstName,
      'lastName': widget.lastName,
      'userName': widget.userName,
      'hasSignUpVerified': false,
      'accessLevel': 1,
      'requestAccepted': 0,
      'requestAdd': 0,
      'requestUpdate': 0
    }).catchError((error) {
      debugState(error.toString());
    });

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 6));
      setState(() => canResendEmail = true);
    } catch (e) {
      debugState(e.toString());
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();

      var uid = FirebaseAuth.instance.currentUser!.uid;

      await dbUser.doc(uid).update({
        'hasSignUpVerified': true 
      }).catchError((error) {
        debugState(error.toString());
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isEmailVerified ? verifyScaffold() : SignInView(
      filledEmail: FirebaseAuth.instance.currentUser!.email!, 
    );
  }

  Scaffold verifyScaffold() {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Container(
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.3, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "A verification email has been sent to your email",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50)
                  ),
                  icon: const Icon(Icons.email, size: 32),
                  label: const Text(
                    "Resent Email",
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: canResendEmail ? sendVerificationEmail : null
                ),
              ],
            )
          )
        ),
      ),
    );
  }
}