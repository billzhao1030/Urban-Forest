import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/account/acknowledge.dart';
import 'package:urban_forest/view/account/sign_in.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:urban_forest/view/main_function/home_screen.dart';
import 'package:urban_forest/view_model/image_recognition.dart';
import 'package:http/http.dart' as http;

bool needSignIn = true; // judge if user need to sign in

void main() async {
  // run the splash animation then initialize environment
  runApp(const SplashScreen());

  // initialize google firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  String email = prefs.getString(loggedInEmail) ?? "";
  String password = prefs.getString(loggedInPassword) ?? "";
  String userUID = prefs.getString(loggedInUID) ?? "";

  // debugState(email);
  // debugState(password);
  // debugState(userUID);

  // if not log out, then sign in automatically
  if (email.isNotEmpty && password.isNotEmpty) {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
    needSignIn = false;
    //debugState("Auto Sign-in");
  }

  // get access level
  if (userUID.isNotEmpty) {
    await dbUser.doc(userUID).get().then((value) {
      var user = UserAccount.fromJson(
        value.data()! as Map<String, dynamic>, 
        value.id
      );

      globalLevel = user.accessLevel;
      //debugState(globalLevel.toString());
    });
  }

  debugState("Initialization finished");
}

// splash screen of the mobile app
// the cloud initialization will be perform during this
class SplashScreen extends StatelessWidget {
  const SplashScreen({ Key? key }) : super(key: key);

  final splashDuration = 2500; // the time duration of this screen

  static const String copyRightInfo = "\u00A9 City of Launceston & University of Tasmania";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      home: Scaffold(
        body: AnimatedSplashScreen(
          duration: splashDuration,
          splashTransition: SplashTransition.scaleTransition,
          pageTransitionType: PageTransitionType.bottomToTop,
          backgroundColor: Color.fromARGB(255, 127, 238, 127),
          nextScreen: const StartApp(), // the next screen
          splashIconSize: 500,
          splash: SingleChildScrollView(
            child: Column(
              children: [
                // logo image
                Image.asset(
                  "assets/images/logo1.png",
                  width: 250,
                  color: Color.fromARGB(104, 5, 148, 24),
                ),
                const SizedBox(
                  height: 40,
                ),

                // app name
                const Text(
                  "Urban Forest",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                // copyright info
                const Text(
                  copyRightInfo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}


class StartApp extends StatefulWidget {
  const StartApp({ Key? key }) : super(key: key);

  @override
  State<StartApp> createState() => _StartAppState();
}

class _StartAppState extends State<StartApp> {
  bool hasAcknowledged = false;
  String email = "";

  @override
  void initState() {
    super.initState();

    getAcknowledge();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green, // primary color
      ),
      home: hasAcknowledged ? (needSignIn ? SignInView(
        filledEmail: email,
      ) : const HomeScreen()) : const Acknowledge(),
    );
  }

  // get the agree status
  void getAcknowledge() async {
    final prefs = await SharedPreferences.getInstance();
    bool acknowledge = prefs.getBool(ack) ?? false;

    debugState(acknowledge.toString());

    setState(() {
      email = prefs.getString(loggedInEmail) ?? "";
      //hasAcknowledged = acknowledge;
      hasAcknowledged = true;
      // TODO: change this back after finish
    });
  }
}
