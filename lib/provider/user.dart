class UserAccount {
  bool hasSignUpVerified = false;

  String uid = "";

  UserAccount();

  UserAccount.fromJson(Map<String,dynamic> json, String uid)
    :
      this.uid = uid,
      hasSignUpVerified = json['hasSignUpVerified'];

  Map<String, dynamic> toJson() =>
  {
    'hasSignUpVerified': hasSignUpVerified
  };
}

