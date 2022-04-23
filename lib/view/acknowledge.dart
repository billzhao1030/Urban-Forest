import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/sign_in.dart';

class Acknowledge extends StatefulWidget {
  const Acknowledge({ Key? key }) : super(key: key);

  @override
  State<Acknowledge> createState() => _AcknowledgeState();
}

class _AcknowledgeState extends State<Acknowledge> {
  bool confirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          backgroundDecoration(context, null),
          acknowledgeDialog()
        ],
      )
    );
  }

  Center acknowledgeDialog() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.6,
        child: AlertDialog(
          title: const Text("title"),
          backgroundColor: const Color.fromARGB(255, 247, 244, 199),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "a\n\nb\n\nc\n\nd\n\ne",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
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