import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/view/sign_in.dart';

import '../utils/debug_format.dart';
import '../utils/reference.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({ Key? key }) : super(key: key);

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
    var uid = FirebaseAuth.instance.currentUser!.uid;

    dbUser.doc(uid).set({
      'uid': uid,
      'hasSignUpVerified': false 
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
      await Future.delayed(const Duration(seconds: 5));
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
    return !isEmailVerified ? Scaffold(
      appBar: AppBar(
        title: Text("Verify"),
      ),

      // TODO: resend button 
      // TODO: cancel button for sign out
    ) : SignInView(filledEmail: FirebaseAuth.instance.currentUser!.email!, filledPassword: "");
  }
}