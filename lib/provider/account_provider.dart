import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:urban_forest/provider/user.dart';
import 'package:urban_forest/utils/debug_format.dart';
import 'package:urban_forest/utils/reference.dart';

class AccountModel extends ChangeNotifier {
  bool? toArcGIS = false;

  UserAccount modelUser = UserAccount();
  String uid = "";

  AccountModel() {
    //fetch(currUser);
    getUpload();
    getUser();
  }


  Future getUpload() async {
    if (globalLevel > 1) {
      debugState("Set firebase");
      toArcGIS = Settings.getValue("key-advanced-upload-ArcGIS", defaultValue: false);
      debugState("Now ${toArcGIS.toString()}");
    }
    

    notifyListeners();
  }

  Future getUser() async {
    uid = FirebaseAuth.instance.currentUser!.uid;
    debugState("now uid: $uid");

    final user = FirebaseAuth.instance.currentUser!;

    await dbUser.doc(user.uid).get().then((value) {
      modelUser = UserAccount.fromJson(
        value.data()! as Map<String, dynamic>,
        value.id
      );
    });
    modelUser.profileToDebug();

    notifyListeners();
  }
}