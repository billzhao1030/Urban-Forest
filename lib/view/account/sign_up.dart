import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:video_player/video_player.dart';

import '../../reusable_widgets/reusable_wiget.dart';
import '../../utils/reference.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({ Key? key, required this.controller }) : super(key: key);
  final VideoPlayerController controller;

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController = TextEditingController();

  final TextEditingController _firstNameTextController = TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // for validation

  VideoPlayerController? _controller;

  bool loading = false;

  bool startVerify = false;

  Timer? timer = Timer(const Duration(seconds: 5), () {});
  bool isEmailVerified = false;
  bool canResendEmail = false;

  @override
  void initState() {
    super.initState();
    // Pointing the video controller to our local asset.
    _controller = VideoPlayerController.asset("assets/images/background.mp4")
      ..initialize().then((_) {
        // Once the video has been loaded we play the video and set looping to true.
        _controller!.play();
        _controller!.setLooping(true);
        // Ensure the first frame is shown after the video is initialized.
        setState(() {});
      });
  }

  @override
  void dispose() {
    _passwordTextController.dispose();
    _emailTextController.dispose();
    _userNameTextController.dispose();
    _confirmPasswordTextController.dispose();
    _firstNameTextController.dispose();
    _lastNameTextController.dispose();

    _controller!.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        widget.controller.play();
        if (startVerify && isEmailVerified) {
          Navigator.pop(context, _emailTextController.text);
          return Future.value(true);
        } else {
          Navigator.pop(context, ' ');
          return Future.value(true);
        }  
      },
      child: GestureDetector(
        onTap: () {
          var currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
    
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              !startVerify ? "Sign Up" : "Verify Email",
              style: const TextStyle(
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
                    height: MediaQuery.of(context).size.height*1.2,
                    child: VideoPlayer(_controller!),
                  ),
                ),
                !startVerify ? 
                  signUpPageView(context) : 
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, MediaQuery.of(context).size.height * 0.4, 20, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "A verification email has been sent to your email (check spam)",
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
              ]
            ),
          )
        ),
      ),
    );
  }

  SingleChildScrollView signUpPageView(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
          
                // first name
                FormTextBox(
                  labelText: "First Name", 
                  icon: Icons.person_outline, 
                  isUserName: true, 
                  isPasswordType: false, 
                  controller: _firstNameTextController,
                  nameField: true,
                ),
                const SizedBox(
                  height: 20,
                ),

                // last name
                FormTextBox(
                  labelText: "Last Name", 
                  icon: Icons.person_outline, 
                  isUserName: true, 
                  isPasswordType: false, 
                  controller: _lastNameTextController,
                  nameField: true,
                ),
                const SizedBox(
                  height: 20,
                ),

                // user name
                FormTextBox(
                  labelText: "Enter User Name", 
                  icon: Icons.person_outline, 
                  isUserName: true, 
                  isPasswordType: false, 
                  controller: _userNameTextController
                ),
                const SizedBox(
                  height: 20,
                ),
          
                // email
                FormTextBox(
                  labelText: "Enter Email", 
                  icon: Icons.email_rounded,
                  isUserName: false, 
                  isPasswordType: false, 
                  controller: _emailTextController
                ),
                const SizedBox(
                  height: 20,
                ),
          
                // password
                FormTextBox(
                  labelText: "Enter Password", 
                  icon: Icons.lock_outlined, 
                  isUserName: false, 
                  isPasswordType: true,
                  controller: _passwordTextController
                ),
                const SizedBox(
                  height: 20,
                ),
          
                // confirm password
                FormTextBox(
                  labelText: "Confirm Password", 
                  icon: Icons.lock_outlined, 
                  isUserName: false, 
                  isPasswordType: true, 
                  controller: _confirmPasswordTextController
                ),
                const SizedBox(
                  height: 20,
                ),
          
                !loading ? firebaseButton(context, "Sign Up", () {
                  // hide current snack bar
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  
                  if (_formKey.currentState!.validate()) {
                    firebaseLoading(true);
                    if (_passwordTextController.text.trim().compareTo(_confirmPasswordTextController.text.trim()) == 0) {
                      FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: _emailTextController.text.trim(), 
                        password: _passwordTextController.text.trim()
                      ).then((value) {
                        setState(() {
                          startVerify = true;
                        });
                        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
                        debugState(FirebaseAuth.instance.currentUser!.uid);

                        var user = FirebaseAuth.instance.currentUser!;
                        var uid = user.uid;

                        dbUser.doc(uid).set({
                          'uid': uid,
                          'email': _emailTextController.text.trim(),
                          'firstName': _firstNameTextController.text.trim(),
                          'lastName': _lastNameTextController.text.trim(),
                          'userName': _userNameTextController.text.trim(),
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

                        firebaseLoading(false);
                      }).onError((error, stackTrace) {
                        onFormSubmitError(error);
                      });
                    } else {
                      showHint(context, "Password didn't match!");

                      firebaseLoading(false);
                    }             
                  }
                }) : Container (
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        )
      );
  } 

  // set the loading state
  void firebaseLoading(bool loading) {
    setState(() {
      this.loading = loading;
    });
  }

  void onFormSubmitError(Object? error) {
    debugState(error.toString());

    var errText = error.toString().substring(15, 18);
    debugState("Firebase error: $errText");

    if (errText.contains("ema")) {
      showHint(context, "The email address is already in use by another account!");
    } else if (errText.contains("too")) {
      showHint(context, "Too many request in a short period! Try again later");
    } else if (errText.contains("inv")) {
      showHint(context, "This email address doesn't exist!");
    } else if (errText.contains("netw")) {
      showHint(context, "There's network issue! Please try again later");
    }

    firebaseLoading(false);
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

      Navigator.pop(context, _emailTextController.text);
    }
  }
}
