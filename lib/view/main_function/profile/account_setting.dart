
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:urban_forest/provider/account_provider.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';
import 'package:urban_forest/reusable_widgets/reusable_wiget.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';
import 'package:urban_forest/view/main_function/profile/profile.dart';
import 'package:urban_forest/view/main_function/profile/user_profile.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({ Key? key, required this.model }) : super(key: key);

  final AccountModel model;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  UserAccount user = UserAccount();

  @override
  void initState() {
    //getUser();

    super.initState();
  }

  getUser() async {
    await widget.model.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleSettingsTile(
      title: 'Account Setting',
      subtitle: 'Privacy, Account, Searching',
      leading: settingIcon(Icons.settings, Colors.green),
      child: SettingsScreen(
        children: [
          //TODO: account page
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SettingsGroup(
              title: "General", 
              children: [
                buildPrivacy(),
                const SizedBox(height: 12,),
                buildProfile()
              ]
            ),
          ),

          const SizedBox(height: 28,),
          (globalLevel > 1) ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: SettingsGroup(
              title: "System Setting", 
              children: [
                buildAdvancedSettings()
              ]
            ),
          ) : Container()
        ]
      ),
    );
  }

  Widget buildPrivacy() => SimpleSettingsTile(
    title: 'Privacy Policy',
    subtitle: '',
    leading: settingIcon(Icons.privacy_tip, Colors.amber),
    child: SettingsScreen(
      title: "Privacy Policy",
      children:[
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: privacyPolicy(),
        )
      ]
    ),
  ); 

  Widget buildProfile() => SimpleSettingsTile(
    title: 'User Profile',
    subtitle: '',
    leading: settingIcon(Icons.person, Colors.green),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(model: widget.model,),
        )
      );
    },
  );

  Widget buildAdvancedSettings() =>  ExpandableSettingsTile(
    leading: const Icon(Icons.developer_mode),
    title: 'Advanced Settings',
    subtitle: 'Map distance, Upload method',
    children: <Widget>[
      SliderSettingsTile(
        title: 'Tree map radius (metres)',
        settingKey: 'key-distance-map',
        defaultValue: 100,
        min: 25,
        max: 250,
        step: 5,
        leading: const Icon(Icons.social_distance),
        onChange: (value) {
          debugPrint('key-distance-map: $value');
        },
      ),

      CheckboxSettingsTile(
        leading: const Icon(Icons.upload),
        settingKey: 'key-advanced-upload-firebase',
        title: 'Upload data to firebase',
        onChange: (value) async {
          debugPrint('key-advanced-upload-firebase: $value');
          await widget.model.getUpload();
        },
      ),
      SimpleSettingsTile(
        title: 'Advanced Settings',
        subtitle: 'These settings is only available for advanced users',
        enabled: false,
      )
    ],
  ); 
}