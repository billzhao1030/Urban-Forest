import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/view/account/sign_in.dart';
import 'package:urban_forest/view/main_function/profile/account_setting.dart';
import 'package:urban_forest/view/main_function/profile/edit_account.dart';

import '../../../utils/color_utils.dart';
import '../../../utils/debug_format.dart';
import '../../../utils/reference.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({ Key? key, required this.user }) : super(key: key);

  final UserAccount user;

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

    widget.user.profileToDebug();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile & Setting",
          textAlign: TextAlign.center,
        ),
        automaticallyImplyLeading: false,
      ),
      body: settingArea(context),
    );
  }

  Widget settingArea(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            widget.user.userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)
          ),
          const SizedBox(height: 4,),
          Text(
            widget.user.emailAddress,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey
            ),
          ),

          Card(
            child: Column(
              children: [
                Text("UID: ${widget.user.uid}")
              ]
            )
          ),
          SettingsGroup(
            title: "GNERAL", 
            children: <Widget>[
              const AccountPage(),
              buildLogout(),
              buildClear(),
              buildDeleteAccount()
            ]
          ),

          const SizedBox(height: 15,),

          SettingsGroup(
            title: "Feedback", 
            children: <Widget>[
              buildReportBug(),
              buildFeedback()
            ]
          ),
        ],
      ),
    );
  }

  Widget buildLogout() => SimpleSettingsTile(
    title: 'Logout',
    subtitle: '',
    leading: settingIcon(Icons.logout, Colors.blueAccent),
    onTap: () async {
      debugState("Logout");
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
  );

  Widget buildDeleteAccount() => SimpleSettingsTile(
    title: 'Delete Account',
    subtitle: '',
    leading: settingIcon(Icons.delete, Colors.redAccent),
    onTap: () {
      debugState("Delete Account");
    },
  );

  Widget buildClear() => SimpleSettingsTile(
    title: 'Clear Data',
    subtitle: '',
    leading: settingIcon(Icons.clear_all, Colors.yellow),
    onTap: () async {
      debugState("Clear Data");

      FirebaseAuth.instance.signOut();
                  
      // set preference
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignInView(filledEmail: email),
        )
      );
    },
  );

  Widget buildReportBug() => SimpleSettingsTile(
    title: 'Report a bug',
    subtitle: '',
    leading: settingIcon(Icons.bug_report, Colors.teal),
    child: SettingsScreen(
      title: "Send feedback",
      children: [
        Text("SAFA")
      ]
    ),
  );

  Widget buildFeedback() => SimpleSettingsTile(
    title: 'Send Feedback',
    subtitle: '',
    leading: settingIcon(Icons.thumb_up, Colors.purple),
    child: SettingsScreen(
      title: "Send feedback",
      children: [
        Text("SAFA")
      ]
    ),
  );

  
}