import 'package:flutter/cupertino.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';

class AccountModel extends ChangeNotifier {
  bool? toFirebase = false;

  UserAccount user = UserAccount();

  AccountModel() {
    //fetch(currUser);
    getUpload();
  }


  Future getUpload() async {
    if (globalLevel > 1) {
      debugState("Set firebase");
      toFirebase = Settings.getValue("key-advanced-upload-firebase", defaultValue: false);
    }
    

    notifyListeners();
  }
}