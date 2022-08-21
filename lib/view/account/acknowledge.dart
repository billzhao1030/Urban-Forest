import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/account/sign_in.dart';
import 'package:video_player/video_player.dart';

class Acknowledge extends StatefulWidget {
  const Acknowledge({ Key? key }) : super(key: key);

  @override
  State<Acknowledge> createState() => _AcknowledgeState();
}

class _AcknowledgeState extends State<Acknowledge> {
  bool confirm = false;
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/images/background.mp4")
      ..initialize().then((_) {
        // Once the video has been loaded we play the video and set looping to true.
        _controller!.play();
        _controller!.setLooping(true);
        // Ensure the first frame is shown after the video is initialized.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
          acknowledgeDialog()
        ],
      )
    );
  }

  Center acknowledgeDialog() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.75,
        child: AlertDialog(
          title: const Text(
            "Terms & Conditions",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color.fromARGB(255, 247, 244, 199),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: privacyPolicy(),
                  ),
                  
                  ListTile(
                    onTap: () {},
                    title: const Text("I have read and acknowledge"),
                    leading: Checkbox(
                      value: confirm, 
                      onChanged: (value) {
                        setState(() {
                          confirm = !confirm;
                        });
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MaterialButton(
              elevation: 5.0,
              textColor: const Color.fromARGB(255, 9, 133, 13),
              child: const Text(
                "Confirm",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
              onPressed: confirm ? () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setBool(ack, true);

                debugState("Acknowledgement page: set ack to true");
    
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInView(
                      filledEmail: "",
                    )
                  )
                );
              } : null,
            )
          ],
        ),
      ),
    );
  }
}