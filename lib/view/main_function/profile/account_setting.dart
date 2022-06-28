import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({ Key? key }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return SimpleSettingsTile(
      title: 'Account Setting',
      subtitle: 'Privacy, Security, Searching',
      leading: settingIcon(Icons.person, Colors.green),
      child: SettingsScreen(
        children: [
          
        ]
      ),
    );
  }
}