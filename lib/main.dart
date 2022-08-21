
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/account/acknowledge.dart';
import 'package:urban_forest/view/account/sign_in.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:urban_forest/view/main_function/home_screen.dart';
import 'package:video_player/video_player.dart';


bool needSignIn = true; // judge if user need to sign in
bool hasInternet = true; // judge if has connection
bool passErrorWhenAutoSignIn = false; // judge if error occur while auto sign in

void main() async {
  hasInternet = await InternetConnectionChecker().hasConnection;
  await Settings.init(cacheProvider: SharePreferenceCache());
  
  // run the splash animation then initialize environment
  runApp(const MaterialApp(home: SplashScreen()));

  // initialize google firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  String email = prefs.getString(loggedInEmail) ?? "";
  String password = prefs.getString(loggedInPassword) ?? "";
  String userUID = prefs.getString(loggedInUID) ?? "";

  debugState("Start up email (pref): $email");
  debugState("Start up password (pref): $password");
  debugState("Start up uid (pref): $userUID");

  // if not log out, then sign in automatically
  if (email.isNotEmpty && password.isNotEmpty) {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, 
      password: password
    ).then((value) {
      needSignIn = false;
      debugState("Auto Sign-in using credential (pref)");
    }).onError((error, stackTrace) {
      needSignIn = true;
      passErrorWhenAutoSignIn = true;
      //debugState("add error detection");
    });
    
  }

  // get access level
  if (userUID.isNotEmpty) {
    await dbUser.doc(userUID).get().then((value) {
      var user = UserAccount.fromJson(
        value.data()! as Map<String, dynamic>, 
        value.id
      );

      globalLevel = user.accessLevel;
      debugState("Start up user level (db) ${globalLevel.toString()}");
    });
  }

  debugState("Initialization finished\n=============================");
}


// splash screen of the mobile app
// the cloud initialization will be perform during this
class SplashScreen extends StatefulWidget {
  const SplashScreen({ Key? key }) : super(key: key);

  static const String copyRightInfo = "\u00A9 City of Launceston & University of Tasmania";

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashDuration = 3000; 
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: AnimatedSplashScreen(
        duration: splashDuration,
        splashTransition: SplashTransition.scaleTransition,
        pageTransitionType: PageTransitionType.bottomToTop,
        backgroundColor: const Color.fromARGB(255, 127, 238, 127),
        nextScreen: hasInternet ? const StartApp() : const CheckInternet(), // the next screen
        splashIconSize: 1.3,
        splash: SingleChildScrollView(
          child: splashContent(width, height)
        ),
      ),
    );
  }

  Column splashContent(double width, double height) {
    return Column(
      children: [
        // logo image
        Image.asset(
          "assets/images/logo1.png",
          width: width * 0.65,
          color: const Color.fromARGB(104, 5, 148, 24),
        ),
        SizedBox(
          height: width * 0.04,
        ),
        // app name
        const Text(
          "Urban Forest",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold
          ),
        ),

        SizedBox(
          height: width * 0.16,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/CityCouncil.png",
              width: width * 0.35,
            ),
            SizedBox(width: width * 0.07,),
            Image.asset(
              "assets/images/UTAS.png",
              width: width * 0.35,
            ),
          ],
        ),

        const SizedBox(
          height: 5,
        ),
        Image.asset(
          "assets/images/PlantNet.png",
          width: width * 0.3,
        ),
      ]
    );
  }
}

// main entry point of the app
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
  void dispose() {
    super.dispose();
  }

  // determine where to go on start
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green, // primary color
      ),
      home: hasAcknowledged 
        ? (
          needSignIn 
          ? (
            passErrorWhenAutoSignIn 
            ? SignInView(
              filledEmail: email, haserror: true,
            ) : SignInView(
              filledEmail: email,
            )
          )
          : const HomeScreen() // go to home screen directly if signed in
        ) 
        : const Acknowledge(),
    );
  }

  // get the agree status
  void getAcknowledge() async {
    final prefs = await SharedPreferences.getInstance();
    bool acknowledge = prefs.getBool(ack) ?? false;

    debugState("Start up acknowledged (pref): ${acknowledge.toString()}");

    setState(() {
      email = prefs.getString(loggedInEmail) ?? "";
      hasAcknowledged = acknowledge;
    });
  }
}


// If no internet connection then show dialog
class CheckInternet extends StatefulWidget {
  const CheckInternet({ Key? key }) : super(key: key);

  @override
  State<CheckInternet> createState() => _CheckInternetState();
}

class _CheckInternetState extends State<CheckInternet> {
  VideoPlayerController? _controller;

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
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.fill,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
            warningDialog()
          ],
        ),
      ),
    );
  }

  Center warningDialog() {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: AlertDialog(
          title: const Text(
            "No Internet found!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color.fromARGB(255, 247, 244, 199),
          content: const Text("Please make sure your mobile device is using WIFI or mobile data"),
          actions: [
            MaterialButton(
              elevation: 5.0,
              textColor: const Color.fromARGB(255, 9, 133, 13),
              child: const Text(
                "OK",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
              onPressed: () {
                SystemNavigator.pop();
              }
            )
          ],
        ),
      )
    );
  }
}

