
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/account/sign_in.dart';
import 'package:urban_forest/view/main_function/tree_form.dart/add_tree.dart';
import 'package:urban_forest/view/main_function/profile/profile.dart';
import 'package:urban_forest/view/main_function/tree_map_arcgis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  late UserAccount currentUser;

  //late TabController _tabController;

  @override
  void initState() {
    super.initState();
    //_tabController = TabController(length: 3, vsync: this);

    getUser();
  }

  // get the signed in user
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
  void dispose() {
    //var email = FirebaseAuth.instance.currentUser!.email!;
    //FirebaseAuth.instance.signOut();

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => SignInView(
    //       filledEmail: "",
    //     )
    //   )
    // );

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return iOSTabBar();
    // return Scaffold(
    //   appBar: PreferredSize(
    //     preferredSize: const Size.fromHeight(0),
    //     child: AppBar(),
    //   ),
    //   body: Stack(
    //     alignment: AlignmentDirectional.topCenter,
    //     children: [
    //       backgroundDecoration(context, null),
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: tabs(),
    //       ),
    //     ],
    //   )
    // );
  }

  Column tabs() {
    return Column(
      children: [
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(25.0)
          ),
          child: TabBar(
            //controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.green[300],
              borderRadius: BorderRadius.circular(25.0)
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            tabs: const [
              Tab(text: 'Map',),
              Tab(text: 'Add',),
              Tab(text: 'Profile',)
            ],
          ),
        ),
        const Expanded(
          child: TabBarView(
            //controller: _tabController,
            children: [
              TreeMap(),
              AddTree(),
              UserProfile()
            ],
          ),
        ),
      ],
    );
  }

  CupertinoTabScaffold iOSTabBar() {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        currentIndex: 1, // default tab
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