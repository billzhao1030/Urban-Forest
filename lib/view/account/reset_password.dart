import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:video_player/video_player.dart';

import '../../reusable_widgets/reusable_methods.dart';
import '../../reusable_widgets/reusable_wiget.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({ Key? key, required this.controller }) : super(key: key);

  final VideoPlayerController controller;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _emailTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // for validation

  final String successSend = "We have sent the password reset email\nYou can close this window safely now";
  bool isSend = false;

  bool loading = false;
  VideoPlayerController? _controller;

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
    _emailTextController.dispose();
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        widget.controller.play();
        Navigator.pop(context, false);
        return Future.value(false);
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
            title: const Text(
              "Reset Password",
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
                  // If your background video doesn't look right, try changing the BoxFit property.
                  // BoxFit.fill created the look I was going for.
                  fit: BoxFit.fill,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
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
                        
                        !loading ? firebaseButton(context, "Reset", () {
                          if (_formKey.currentState!.validate()) {
                            firebaseLoading(true);
      
                            FirebaseAuth.instance
                            .sendPasswordResetEmail(email: _emailTextController.text.trim())
                            .then((value) {
                              setState(() {
                                isSend = true;
                              });
                              firebaseLoading(false);
                            })
                            .onError((error, stackTrace) {
                              debugState("Error: ${error.toString()}");
      
                              var errText = error.toString().substring(15, 21);
                              debugState("Firebase error: $errText");
                                
                              if (errText.contains("too")) {
                                showHint(context, "Too many request in a short period! Try again later");
                              } else if (errText.contains("user-d")) {
                                showHint(context, "The user account has been disabled by an administrator");
                              } else if (errText.contains("user-n")){
                                showHint(context, "This email doesn't link to an account! Please sign up");
                              } else if (errText.contains("inv")) {
                                showHint(context, "This email address doen't exist!");
                              } else if (errText.contains("netw")) {
                                showHint(context, "There's network issue! Please try again later");
                              }
      
                              firebaseLoading(false);
                            });
                          }
                        }) : Container (
                          margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        
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
                  ),
                ),
              ],
            )
          ),
        ),
      ),
    );
  } 

  // set the loading state
  void firebaseLoading(bool loading) {
    setState(() {
      this.loading = loading;
    });
  }
}
