import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/view/verify_email.dart';

import '../reusable_widgets/reusable_wiget.dart';
import '../utils/color_utils.dart';
import '../utils/reference.dart';
import 'home_screen.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({ Key? key }) : super(key: key);

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _userNameTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // for validation

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
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
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VerifyEmail()
                            )
                          );
                          firebaseLoading(false);
                        }).onError((error, stackTrace) {
                          debugState(error.toString());

                          var errText = error.toString().substring(15, 18);
                          debugState(errText);
                          var snackBarText = "";
                          if (errText.contains("ema")) {
                            snackBarText = "The email address is already in use by another account!";
                          } else if (errText.contains("too")) {
                            snackBarText = "Too many request in a short period! Try again later";
                          } else if (errText.contains("inv")) {
                            snackBarText = "This email address doen't exist!";
                          }
                          
                          ScaffoldMessenger.of(context).showSnackBar(snackBarHint(snackBarText));

                          firebaseLoading(false);
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
        )
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
