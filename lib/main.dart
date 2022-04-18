import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/view/sign_in.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

const background_color_array = ["afef8d", "23cb23", "225508"];

void main() async {
  runApp(const SplashScreen());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  debugState("Firebase initialized");
}

// splash screen of the mobile app
// the cloud initialization will be perform during this
class SplashScreen extends StatelessWidget {
  const SplashScreen({ Key? key }) : super(key: key);

  final splashDuration = 2500; // the time duration of this screen

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
          splashIconSize: 400,
          splash: SingleChildScrollView(
            child: Column(children: [
              Image.asset(
                "assets/images/logo1.png",
                width: 250,
              ),
              const Text(
                "Urban Forest",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              )
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
