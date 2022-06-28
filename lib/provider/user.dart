// ignore_for_file: prefer_initializing_formals

import 'package:urban_forest/utils/debug_format.dart';

class UserAccount {
  bool hasSignUpVerified = false;

  String firstName = "";
  String lastName = "";
  String userName = "";
  String emailAddress = "";

  String uid = "";

  int accessLevel = 0;

  String? phoneNumber;

  int requestAdd = 0; // 6 points
  int requestUpdate = 0; // 4 points
  int requestAccepted = 0; // 10 points 

  int get levelPoints {
    return 6 * requestAdd + 4 * requestUpdate + 10 * requestAccepted;
  }

  String get levelName {
    if (levelPoints < 10) {
      return "Tree Starter";
    } else if (levelPoints < 30) {
      return "Tree Junior";
    } else if (levelPoints < 70) {
      return "Tree Senior";
    } else if (levelPoints < 150) {
      return "Tree Hero";
    } else {
      return "Tree Legend";
    }
  }

  UserAccount();

  void profileToDebug() {
    var debugStr = "\nUser profile:\n"
    "$firstName $lastName, username: $userName, email: $emailAddress\n"
    "uid: $uid, access level: $accessLevel, verified: $hasSignUpVerified\n"
    "requestAdd: $requestAdd, requestUpdate: $requestUpdate, requestAccepted: $requestAccepted";
    debugState(debugStr);
  }

  UserAccount.fromJson(Map<String,dynamic> json, String uid)
    :
      uid = uid,
      firstName = json['firstName'],
      lastName = json['lastName'],
      userName = json['userName'],
      emailAddress = json['email'],
      accessLevel = json['accessLevel'],
      hasSignUpVerified = json['hasSignUpVerified'],
      requestAdd = json['requestAdd'],
      requestUpdate = json['requestUpdate'],
      requestAccepted = json['requestAccepted'];
      

  Map<String, dynamic> toJson() =>
  {
    'hasSignUpVerified': hasSignUpVerified
  };
}
