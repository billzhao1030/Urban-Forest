import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/view/sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key, required this.fromLogIn }) : super(key: key);

  final bool fromLogIn;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("${FirebaseAuth.instance.currentUser?.displayName}"),
            ElevatedButton(
              child: Text("${(FirebaseAuth.instance.currentUser?.email)}"),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInView(
                        filledEmail: "",
                        filledPassword: "",
                      ),
                    )
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  } 
}