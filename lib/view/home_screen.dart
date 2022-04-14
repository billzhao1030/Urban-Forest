import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/view/sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("${(FirebaseAuth.instance.currentUser?.email)}"),
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInView(),
                )
              );
            });
          },
        ),
      ),
    );
  }
}