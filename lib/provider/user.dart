import 'package:flutter/cupertino.dart';
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

  int requestAdd = 0;
  int requestUpdate = 0;
  int requestAccepted = 0;

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


// user account provider
class UserModel extends ChangeNotifier {

}

