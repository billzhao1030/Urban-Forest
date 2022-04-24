import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/add_tree.dart';
import 'package:urban_forest/view/profile.dart';
import 'package:urban_forest/view/sign_in.dart';
import 'package:urban_forest/view/tree_map_arcgis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key, required this.fromLogIn }) : super(key: key);

  final bool fromLogIn;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserAccount currentUser;

  TextEditingController _passwordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getUser();
  }

  void getUser() async {
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
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoColors.tertiarySystemBackground,
        activeColor: CupertinoColors.activeGreen,
        
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(CupertinoIcons.map)
          ),
          BottomNavigationBarItem(
            label: 'Add',
            icon: Icon(CupertinoIcons.add_circled)
          ),
          BottomNavigationBarItem(
            label: 'Profile',
            icon: Icon(CupertinoIcons.profile_circled)
          )
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0: 
            return const TreeMap();
          case 1:
            return const AddTree();
          case 2:
          default:
            return const UserProfile();
        }
      },
    );
  }
}