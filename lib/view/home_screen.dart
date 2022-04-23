import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key, required this.fromLogIn }) : super(key: key);

  final bool fromLogIn;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserAccount currentUser;

  @override
  Future<void> initState() async {
    super.initState();

    final user = FirebaseAuth.instance.currentUser!;

    await dbUser.doc(user.uid).get().then((value) {
      currentUser = UserAccount.fromJson(
        value.data()! as Map<String, dynamic>,
        value.id
      );
    });
    currentUser.profileToDebug();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("log out"),
            ElevatedButton(
              child: Text("${(FirebaseAuth.instance.currentUser?.email)}"),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInView(
                        filledEmail: "",
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