import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/controller/image_recognition.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/view/sign_in.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

const backgroundColorArray = ["afef8d", "23cb23", "225508"];

void main() async {
  //runApp(const SplashScreen());
  runApp(const AITemp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  debugState("Firebase initialized");
}

// splash screen of the mobile app
// the cloud initialization will be perform during this
class SplashScreen extends StatelessWidget {
  const SplashScreen({ Key? key }) : super(key: key);

  final splashDuration = 3000; // the time duration of this screen

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: AnimatedSplashScreen(
          duration: splashDuration,
          splashTransition: SplashTransition.scaleTransition,
          pageTransitionType: PageTransitionType.bottomToTop,
          backgroundColor: const Color.fromARGB(255, 165, 229, 165),
          nextScreen: const MyApp(),
          splashIconSize: 500,
          splash: SingleChildScrollView(
            child: Column(children: [
              // logo image
              Image.asset(
                "assets/images/logo1.png",
                width: 250,
                color: const Color.fromARGB(138, 14, 150, 32),
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
                "\u00A9 City of Launceston & University of Tasmania",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //print("${FirebaseAuth.instance.currentUser?.email}");

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SignInView(),
    );
  }
}
