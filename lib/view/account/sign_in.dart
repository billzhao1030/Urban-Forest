import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/account/reset_password.dart';
import 'package:video_player/video_player.dart';

import '../../reusable_widgets/reusable_wiget.dart';
import '../main_function/home_screen.dart';
import 'sign_up.dart';


const logoFileName = "assets/images/logo2.png"; // logo in assets/images

// sign in view -- root widget for sign in
class SignInView extends StatefulWidget {
  const SignInView({
    Key? key, 
    required this.filledEmail, 
    this.haserror// pre-entered email
  }) : super(key: key);

  final String filledEmail;
  final bool? haserror;

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // for validation
  VideoPlayerController? _controller;

  bool loading = false;

  @override
  void dispose() {
    _passwordTextController.dispose();
    _emailTextController.dispose();
    _controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _controller = VideoPlayerController.asset("assets/images/background.mp4")
      ..initialize().then((_) {
        // Once the video has been loaded we play the video and set looping to true.
        _controller!.play();
        _controller!.setLooping(true);
        // Ensure the first frame is shown after the video is initialized.
        setState(() {});
      });

    // set the controller text if has pre-entered fields
    _emailTextController.text = widget.filledEmail;

    if (widget.haserror != null) {
      Future.delayed(Duration.zero, () {
        showHint(context, "Error occurs when sign in\nYour account is diabled/deleted by admin", keep: true);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      child: Scaffold(
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
              signInPageView(context)
            ]
          ),
        ),
      ),

    );
  }

  Padding signInPageView(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).size.height * 0.16, 20, 0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            // logo
            const LogoWidget(),
            const SizedBox(
              height: 45,
            ),

            // email for sign in
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

            // password for sign in
            FormTextBox(
              labelText: "Enter Password", 
              icon: Icons.lock_outline, 
              isUserName: false, 
              isPasswordType: true, 
              controller: _passwordTextController
            ),
            const SizedBox(
              height: 8,
            ),

            // forget password
            forgetPassword(),

            // sign in
            !loading ? firebaseButton(context, "Log In", () {
              // hide the current snackbar
              ScaffoldMessenger.of(context).hideCurrentSnackBar();

              // perform frontend validation
              if (_formKey.currentState!.validate()) {
                firebaseLoading(true);

                // check email and password
                FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: _emailTextController.text.trim(), 
                  password: _passwordTextController.text.trim()
                ).then((value) async {
                  firebaseSignIn(value);
                }).onError((error, stackTrace) {
                  onFormSubmitError(error);
                });
              }
            }) : Container (
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: const CircularProgressIndicator(
                color: Colors.white,
              ),
            ),

            // sign up section
            signUp()
          ]
        ),
      )
    );
  }

  // change the loading state
  void firebaseLoading(bool loading) {
    setState(() {
      this.loading = loading;
    });
  }

  Future<void> firebaseSignIn(UserCredential value) async {
    // get the uid
    var uid = FirebaseAuth.instance.currentUser!.uid;
    UserAccount user;

    // get the state of email verification and update if true
    bool isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    //debugState(isEmailVerified.toString());

    if (isEmailVerified) {
      await dbUser.doc(uid).update({
        'hasSignUpVerified' : isEmailVerified
      }).catchError((error) {
        showHint(context, "Error when authenticating!");
      });
    }

    // if the this account never verified
    await dbUser.doc(uid).get().then((value) async {
      user = UserAccount.fromJson(
        value.data()! as Map<String, dynamic>, 
        value.id
      );

      // user.profileToDebug(); // DEBUG

      if (user.hasSignUpVerified) {
        // set the shared preference
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(loggedInEmail, _emailTextController.text.trim());
        prefs.setString(loggedInPassword, _passwordTextController.text.trim());
        prefs.setString(loggedInUID, uid);

        // update the gloabl level
        globalLevel = user.accessLevel;
        debugState("Now global level change to $globalLevel");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          )
        );
        firebaseLoading(false);
      } else {
        showHint(context, "You have not verified this email yet!", verify: true);

        firebaseLoading(false);

        // maybe sign out first?
        FirebaseAuth.instance.signOut();
      }
    });
  }

  //firebase sign in error 
  void onFormSubmitError(Object? error) {
    setState(() {
      debugState(error.toString());

      var errText = error.toString().substring(15, 21);
      debugState("Firebase error: $errText");
      
      if (errText.contains("wro")) {
        showHint(context, "Wrong email or password! Please try again");
      } else if (errText.contains("too")) {
        showHint(context, "Too many requests in a short period! Try again later");
      } else if (errText.contains("user-d")) {
        showHint(context, "The user account has been disabled by an administrator");
      } else if (errText.contains("user-n")) {
        showHint(context, "This email doesn't link to an account! Please sign up");
      } else if (errText.contains("netw")) {
        showHint(context, "There's network issue! Please try again later");
      }
      
      loading = false;
    });
  }

  Row signUp(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have account?   ",
          style: TextStyle(color: Colors.white),
        ),
        GestureDetector(
          onTap: () async {
            _emailTextController.text = await Navigator.push(
              context, 
              MaterialPageRoute(
                builder: ((context) {
                  return SignUpView(controller: _controller!,);
                })
              )
            );
            showHint(context, 'Email verified!');
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              fontStyle: FontStyle.italic
            ),
          ),
        )
      ],
    );
  }

  Widget forgetPassword() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.right,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordView(controller: _controller!,),
            )
          );
        },
      ),
    );
  }
}


// widget of logo image -- stateless
class LogoWidget extends StatelessWidget {
  const LogoWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      logoFileName,
      fit: BoxFit.fitHeight,
      width: MediaQuery.of(context).size.height * 0.25,
      height: MediaQuery.of(context).size.height * 0.25,
      color: Colors.white,
    );
  }
}



