import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/view/sign_in.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

const background_color_array = ["afef8d", "23cb23", "225508"];


void main() async {
  runApp(const SplashScreen());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: AnimatedSplashScreen(
          duration: 3000,
          splashTransition: SplashTransition.scaleTransition,
          pageTransitionType: PageTransitionType.bottomToTop,
          backgroundColor: Colors.greenAccent,
          nextScreen: const MyApp(),
          splashIconSize: 400,
          splash: Image.asset("assets/images/logo2.png"),
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
