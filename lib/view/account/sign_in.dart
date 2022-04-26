import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/account/reset_password.dart';

import '../../reusable_widgets/reusable_wiget.dart';
import '../main_function/home_screen.dart';
import 'sign_up.dart';

const logoFileName = "assets/images/logo2.png"; // logo in assets/images


// sign in view -- root widget for sign in
class SignInView extends StatefulWidget {
  const SignInView({
    Key? key, 
    required this.filledEmail, // pre-entered email
  }) : super(key: key);

  final String filledEmail;

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // for validation

  bool loading = false;

  @override
  void initState() {
    super.initState();

    // set the controller text if has pre-entered fields
    _emailTextController.text = widget.filledEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: backgroundDecoration(
        context, 
        signInPageView(context)
      )
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
            const ForgetPassword(),

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
            const SignUpOption()
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
    debugState(isEmailVerified.toString());

    if (isEmailVerified) {
      await dbUser.doc(uid).update({
        'hasSignUpVerified' : isEmailVerified
      }).catchError((error) {
        showHint(context, "Error when authenticating!");
      });
    }

    // if the this account never verified
    await dbUser.doc(uid).get().then((value) {
      user = UserAccount.fromJson(
        value.data()! as Map<String, dynamic>, 
        value.id
      );

      user.profileToDebug(); // DEBUG

      if (user.hasSignUpVerified) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          )
        );
        firebaseLoading(false);
      } else {
        showHint(context, "You have not verify this email yet!", verify: true);

        firebaseLoading(false);
      }
    });
  }

  //firebase sign in error 
  void onFormSubmitError(Object? error) {
    setState(() {
      debugState(error.toString());

      var errText = error.toString().substring(15, 21);
      debugState(errText);
      
      if (errText.contains("wro")) {
        showHint(context, "Wrong email or password! Please try again");
      } else if (errText.contains("too")) {
        showHint(context, "Too many request in a short period! Try again later");
      } else if (errText.contains("user-d")) {
        showHint(context, "The user account has been disabled by an administrator");
      } else if (errText.contains("user-n")) {
        showHint(context, "This email doesn't link to an account! Please sign up");
      }
      
      loading = false;
    });
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
      width: MediaQuery.of(context).size.height * 0.3,
      height: MediaQuery.of(context).size.height * 0.3,
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