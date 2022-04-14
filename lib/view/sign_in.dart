import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/main.dart';
import 'package:urban_forest/utils/color_utils.dart';
import 'package:urban_forest/view/reset_password.dart';

import '../reusable_widgets/reusable_wiget.dart';
import 'home_screen.dart';
import 'sign_up.dart';

const logoFileName = "assets/images/logo1.png"; // logo in assets/images

class SignInView extends StatefulWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringToColor(background_color_array[0]),
              hexStringToColor(background_color_array[1]),
              hexStringToColor(background_color_array[2]),
            ], 
            begin: Alignment.topCenter, 
            end: Alignment.bottomCenter
          )
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.2, 20, 0),
            child: Column(
              children: <Widget>[
                logoWidget(logoFileName),
                const SizedBox(
                  height: 30,
                ),
                reusableTextField("Enter UserName", Icons.person_outline, false, _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                reusableTextField("Enter Password", Icons.lock_outline, true, _passwordTextController),
                const SizedBox(
                  height: 8,
                ),

                // forget password
                forgetPassword(context),

                // sign in
                firebaseButton(context, "Log In", () {
                  // debug input
                  print("${_emailTextController.text}");
                  print("${_passwordTextController.text}");

                  // check email and password
                  FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _emailTextController.text, 
                    password: _passwordTextController.text
                  ).then((value) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        )
                      );
                    }
                  ).onError((error, stackTrace) {
                    print("Error: ${error.toString()}");
                  });
                }),

                // sign up
                signUpOption()
              ]
            ),
          )
        ),
      ),
    );
  }

  // sign up section
  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have account? ",
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
              fontWeight: FontWeight.bold
            ),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
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
