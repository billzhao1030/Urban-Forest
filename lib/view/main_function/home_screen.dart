
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/main_function/add_tree.dart';
import 'package:urban_forest/view/main_function/profile/profile.dart';
import 'package:urban_forest/view/main_function/tree_map_arcgis.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  late UserAccount currentUser;
  final CupertinoTabController _tabController = CupertinoTabController(initialIndex: 1);

  @override
  void initState() {
    getUser();
    super.initState();
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
  }

  CupertinoTabScaffold iOSTabBar() {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        currentIndex: 1, // default tab
        backgroundColor: CupertinoColors.tertiarySystemBackground,
        activeColor: CupertinoColors.activeGreen,
        
        items: const [
          BottomNavigationBarItem(
            label: 'Map',
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
            return TreeMap(controller: _tabController);
          case 1:
            return const UploadTree();
          case 2:
            return const UserProfile();
          default:
            return TreeMap(controller: _tabController);
        }
      },
    );
  }
}