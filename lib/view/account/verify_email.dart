import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/view/account/sign_in.dart';
import 'package:video_player/video_player.dart';
import '../../utils/debug_format.dart';
import '../../utils/reference.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({ 
    Key? key, 
    required this.firstName, 
    required this.lastName, 
    required this.userName, 
    required this.controller 
  }) : super(key: key);

  final String firstName;
  final String lastName;
  final String userName;
  final VideoPlayerController controller;

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  Timer? timer;
  bool isEmailVerified = false;
  bool canResendEmail = false;

  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/images/background.mp4")
      ..initialize().then((_) {
        // Once the video has been loaded we play the video and set looping to true.
        _controller!.play();
        _controller!.setLooping(true);
        // Ensure the first frame is shown after the video is initialized.
        setState(() {});
      });

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
    _controller!.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isEmailVerified ? verifyScaffold() : SignInView(
      filledEmail: FirebaseAuth.instance.currentUser!.email!, 
    );
  }

  Widget verifyScaffold() {
    return WillPopScope(
      onWillPop: () {
        widget.controller.play();
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "Verify Email",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold
              ),
            ),
        ),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0.4, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "A verification email has been sent to your email",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
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
              ),
            ],
          )
        ),
      ),
    );
  }
}