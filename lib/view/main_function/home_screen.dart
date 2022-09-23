
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urban_forest/provider/account_provider.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/main_function/upload_tree.dart';
import 'package:urban_forest/view/main_function/profile/profile_setting.dart';
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
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: Colors.green, // primary color
      ),
      child: ChangeNotifierProvider(
        create: (context) => AccountModel(),
        child: GestureDetector(
          onTap: () {
            var currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Consumer<AccountModel> (
            builder: iOSTabBar,
          )
        ),
      ),
    );
  }

  CupertinoTabScaffold iOSTabBar(BuildContext context, AccountModel userModel, _) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        currentIndex: 1, // default tab
        backgroundColor: CupertinoColors.tertiarySystemBackground,
        activeColor: CupertinoColors.activeGreen,
        
        items: const [
          BottomNavigationBarItem(
            label: 'Tree Map',
            icon: Icon(CupertinoIcons.map)
          ),
          BottomNavigationBarItem(
            label: 'Add Tree',
            icon: Icon(CupertinoIcons.add_circled)
          ),
          BottomNavigationBarItem(
            label: 'Profile/Setting',
            icon: Icon(CupertinoIcons.profile_circled)
          )
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0: 
            return TreeMap(controller: _tabController, model: userModel,);
          case 1:
            return UploadTree(model: userModel,);
          case 2:
            return UserProfile(user: currentUser, model: userModel,);
          default:
            return TreeMap(controller: _tabController, model: userModel,);
        }
      },
    );
  }
}