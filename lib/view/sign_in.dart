import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/main.dart';
import 'package:urban_forest/utils/color_utils.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/view/reset_password.dart';

import '../reusable_widgets/reusable_wiget.dart';
import 'home_screen.dart';
import 'sign_up.dart';

const logoFileName = "assets/images/logo2.png"; // logo in assets/images


// sign in view -- root widget for sign in
class SignInView extends StatefulWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // for validation

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  // logo
                  const LogoWidget(),
                  const SizedBox(
                    height: 30,
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
                  const ForgetPassword(),

                  // sign in
                  !loading ? firebaseButton(context, "Log In", () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                      });
                      // check email and password
                      FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailTextController.text, 
                        password: _passwordTextController.text
                      ).then((value) {
                        loading = false;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            )
                          );
                        }
                      ).onError((error, stackTrace) {
                        setState(() {
                          loading = false;
                          debugState(error.toString().substring(15, 18));

                          var errText = error.toString().substring(15, 18);
                          var snackBarText = "";
                          if (errText.contains("w")) {
                            snackBarText = "Wrong email or password! Please try again.";
                          } else {
                            snackBarText = "Too many request in a short period! Try again later";
                          }
                          
                          ScaffoldMessenger.of(context).showSnackBar(snackBarHint(snackBarText));
                        });
                      });
                    }
                  }) : Container(
                    margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),

                  // sign up section
                  const SignUpOption()
                ]
              ),
            )
          )
        ),
      ),
    );
  }

  // snack bar hint about authentication state
  SnackBar snackBarHint(String hint) {
    return SnackBar(
      backgroundColor: const Color.fromARGB(255, 187, 173, 132),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      behavior: SnackBarBehavior.floating,
      content: Text(
        hint,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 15
        ),
      ),
      duration: const Duration(milliseconds: 3000),
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
      width: 320,
      height: 320,
      color: Colors.white,
    );
  }
}

// widget of forget password button -- stateless
class ForgetPassword extends StatelessWidget {
  const ForgetPassword({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResetPasswordView(),
            )
          );
        },
      ),
    );
  }
}

// widget of sign up section -- stateless
class SignUpOption extends StatelessWidget {
  const SignUpOption({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have account?   ",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: ((context) {
                  return const SignUpView();
                })
              )
            );
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
}