import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/view/sign_in.dart';

import '../utils/debug_format.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({ Key? key }) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final user = FirebaseAuth.instance.currentUser!;
  var email = "";

  @override
  void initState() {
    super.initState();

    setState(() {
      email = user.email!;
    });

    debugState(email);
  }

  @override
  Widget build(BuildContext context) {
    return backgroundDecoration(
      context, 
      Container(
        //child: Text("${user.email}")
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
              child: Text("log out"),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInView(filledEmail: email),
                  )
                );
              },
            ),
          ],
        ),
      )
    );
  }
}