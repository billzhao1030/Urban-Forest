import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/view/account/sign_in.dart';
import 'package:urban_forest/view/main_function/profile/edit_account.dart';

import '../../../utils/debug_format.dart';
import '../../../utils/reference.dart';

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

    debugState("access level: $globalLevel");

    setState(() {
      email = user.email!;
    });

    debugState(email);
  }

  @override
  Widget build(BuildContext context) {
    return backgroundDecoration(
      context,
      profile(context)
    );
  }

  Widget profile(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Row(
            children: [
              ElevatedButton(
                child: const Text("My Account"),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAccount(userUID: user.uid,),
                    )
                  );
                },
              ),
              ElevatedButton(
                child: const Text("log out"),
                onPressed: () async {
                  FirebaseAuth.instance.signOut();

                  // set preference
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString(loggedInPassword, "");

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
        ],
      ),
    );
  }
}